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

let set_group_room model room_id =
  Js.log "setting group room";
  match Js.String.charAt 0 room_id with
    | "!" -> Tea.Cmd.msg (SetCurrentRoom room_id)
    | "#" -> resolve_alias_cmd model room_id
    | _ -> Tea.Cmd.none

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

let iri_to_label iri =
  iri
  |> Js.String.replace "http://www.wikidata.org/entity/" "#_stm_wd_"
  |> Js.String.concat ":matrix.imago.local"

let view_room _model room =
  let statements = statements room in
  let open Tea.Html in
  let obj_view _property (obj : Statements.obj) =
    div
      [ id "object-item" ]
      [ Router.link goTo (Group (iri_to_label obj##iri)) [ text
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
    div
      [ id "statements-list" ]
      (Belt.Map.toList statements |. Belt.List.map statement_view)
  in
  let events_list = div [ id "events-list" ] [] in
  div ~unique:"group" ~key:room##roomId [] [ statements_list; events_list ]

let view model _room_id =
  let open Tea.Html in
  match model.current_room with
  | Some room ->
      view_room model room
  | None ->
      div [] [text "Room not found"]
