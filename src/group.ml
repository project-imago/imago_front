type msg =
  | GoTo of Router.route
  | SetCurrentRoom of Matrix.room_id
  | GotRoomId of (<room_id : string> Js.t, string) Tea.Result.t
  | Peeked of (Matrix.room, string) Tea.Result.t
  [@@bs.deriving { accessors }]

type model = { matrix_client : Matrix.client ref ;
  current_room : Matrix.room option
}

let init matrix_client = { current_room = None; matrix_client }

let resolve_alias_cmd model room_alias =
  Tea_promise.result (!(model.matrix_client)##resolveRoomAlias room_alias)
  gotRoomId

let peek_room_cmd model room_id =
  Tea_promise.result (!(model.matrix_client)##peekInRoom room_id)
  peeked

let set_group_room model = function
  | Matrix.Id room_id -> Tea.Cmd.msg (SetCurrentRoom room_id)
  | Alias room_alias -> resolve_alias_cmd model room_alias

let update model = function
  | SetCurrentRoom room_id ->
      let room_in_store = !(model.matrix_client)##getRoom room_id |>
      Js.Nullable.toOption in
      (match room_in_store with
      | Some room ->
          Js.log ("there's room"); Js.log room;
          ({model with current_room = Some room}, Tea.Cmd.none)
      | None ->
          Js.log "peek";
          (model, peek_room_cmd model room_id))
  | GotRoomId (Tea.Result.Ok res) ->
      let () = Js.log "matrix alias resolved" in
      (model, Tea.Cmd.msg (SetCurrentRoom res##room_id))
  | GotRoomId (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)
  | Peeked (Tea.Result.Ok room) ->
      ({model with current_room = Some room}, Tea.Cmd.none)
  | Peeked (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)
  | GoTo _ -> (model, Tea.Cmd.none)

let statements room =
  (* let room_state = room##currentState in *)
  (* let statements_states = Matrix.StatementState.get room_state "pm.imago.group" None in *)
  let room_state = room##currentState in
  let maybe_statements_state =
    Statements.StatementState.get_one room_state "pm.imago.group.statements" ""
  in
  match Js.Nullable.toOption maybe_statements_state with
  | None -> Statements.empty
  | Some statement_state ->
    Statements.build_from_state statement_state

let iri_to_alias iri =
  iri
  |> Js.String.replace "http://www.wikidata.org/entity/" "#_stm_wd_"
  |> Js.String.concat ":matrix.imago.local"

let view_room _model room =
  let room_id = room##roomId in
  let statements = statements room in
  let open Tea.Html in
  let obj_view _property (obj : Statements.obj) =
    div
      [ id "object-item" ]
      [ Router.link goTo (Group (Alias (iri_to_alias obj##iri))) [ text
      obj##label ] ]
  in
  let statement_view (property, objs) =
    div
      [ id "statement-item" ]
      [ div [ id "property-item" ] [ text property##label ]
      ; div
          [ id "objects-list" ]
          (Belt.Array.map objs (obj_view property) |> Belt.List.fromArray)
      ]
  in
  let statements_list =
    Js.log "statements"; Js.log statements; Js.log room;
    div ~unique:room_id
      [ id "statements-list" ]
      (Belt.Map.toList statements |. Belt.List.map statement_view)
  in
  let events_list = div ~unique:room_id [ id "events-list" ] [] in
  div ~unique:"group" ~key:room##roomId [id "group-view"] [  h3 [] [text room##name]; statements_list; events_list ]

let view model =
  let open Tea.Html in
  match model.current_room with
  | Some room ->
      view_room model room
  | None ->
      div [] [text "Room not found"]
