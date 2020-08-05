type msg =
  | GoTo of Router.route
  | SetCurrentRoom of Matrix.room_id
  | GotRoomId of (<room_id : string> Js.t, string) Tea.Result.t
  | Peeked of (Matrix.room, string) Tea.Result.t
  | ToggleShowStatements
  | ToggleShowChats
  | ToggleShowEvents
  [@@bs.deriving { accessors }]

type model =
  { matrix_client : Matrix.client ref
  ; current_room : Matrix.room option
  ; show_statements : bool
  ; show_chats : bool
  ; show_events : bool
  }

let init matrix_client =
  { current_room = None
  ; matrix_client
  ; show_statements = true
  ; show_chats = false
  ; show_events = true
  }

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
          ({model with current_room = Some room}, Tea.Cmd.none)
      | None ->
          (model, peek_room_cmd model room_id))
  | GotRoomId (Tea.Result.Ok res) ->
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
  | ToggleShowStatements ->
      ({ model with show_statements = not model.show_statements }, Tea.Cmd.none)
  | ToggleShowChats ->
      ({ model with show_chats = not model.show_chats }, Tea.Cmd.none)
  | ToggleShowEvents ->
      ({ model with show_events = not model.show_events }, Tea.Cmd.none)

let statements room =
  (* let room_state = room##currentState in *)
  (* let statements_states = Matrix.StatementState.get room_state "pm.imago.group" None in *)
  let room_state = room##currentState in
  let state_events =
    Statements.StatementState.get room_state "pm.imago.statement"
  in
  Statements.build_from_state_events state_events

let iri_to_alias iri =
  iri
  |> Js.String.replace "http://www.wikidata.org/entity/" "#_stm_wd_"
  |> Js.String.concat ":"
  |> Js.String.concat Config.matrix_homeserver

let view_statements model room =
  let room_id = room##roomId in
  let statements = statements room in
  let room_state = room##currentState in
  let localized_label iri =
    let event = Statements.ObjectState.get_one_exn room_state "pm.imago.object" iri
    in
    (event##getContent ())##label |. Statements.get_localized !Locale.get
  in
  let open Tea.Html in
  let obj_view _property (obj : Statements.obj) =
    div
      [ id "object-item" ]
      [ Router.link goTo (Group (Alias (iri_to_alias obj))) [ text
      (localized_label obj) ] ]
  in
  let statement_view (property, objs) =
    div
      [ id "statement-item" ]
      [ div [ id "property-item" ] [ text (localized_label property) ]
      ; div
          [ id "objects-list" ]
          (Belt.Array.map objs (obj_view property) |> Belt.List.fromArray)
      ]
  in
  let statements_list =
    (*Js.log "statements"; Js.log statements; Js.log room;*)
    div ~unique:room_id
      [ id "statements-list" ]
      (Belt.Map.toList statements |. Belt.List.map statement_view)
  in
  div ~unique:"group"
  [ id "statements"
  ; classList
      [ ("visible", model.show_chats)
      ]
  ]
  [statements_list]

let view_chats model _room =
  let open Tea.Html in
  div
    [ id "chats"
    ; classList
        [ ("visible", model.show_chats)
        ]
    ]
    []

let view_events model _room =
  let open Tea.Html in
  div
    [ id "events"
    ; classList
        [ ("visible", model.show_events)
        ]
    ]
    []

let toggle_button title' active msg =
        Js.log title';
        Js.log active;
  let open Tea.Html in
  match active with
  | true ->
    button ~unique:"true" [ onClick msg ]
    [h3 [] [ Icons.icon "chevron-bottom"; text title']]
  | false ->
    button ~unique:"false" [ onClick msg ]
    [h3 [] [ Icons.icon "chevron-right"; text title']]

let view_room model room =
  let open Tea.Html in
  div ~unique:("group" ^ room##roomId)
  [id "group-view"]
  [ h3 [] [text room##name]
  ; toggle_button (T.group_links_title ()) model.show_statements ToggleShowStatements
  ; view_statements model room
  ; toggle_button (T.group_chats_title ()) model.show_chats ToggleShowChats
  ; view_chats model room
  ; toggle_button (T.group_events_title ()) model.show_events ToggleShowEvents
  ; view_events model room
  ]

let view model =
  let open Tea.Html in
  match model.current_room with
  | Some room ->
      view_room model room
  | None ->
      div [] [text (T.group_room_not_found ())]
