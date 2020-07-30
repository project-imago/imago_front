type msg =
  | GoTo of Router.route
  | SetCurrentRoom of Matrix.room_id
  | GotRoomId of (<room_id : string> Js.t, string) Tea.Result.t
  | Peeked of (Matrix.room, string) Tea.Result.t
  | SaveMessage of Matrix.room_id * string
  | SendMessage of Matrix.room_id * string
  | SentMessage of (<event_id : string> Js.t, string) Tea.Result.t
[@@bs.deriving { accessors }]

type model =
  { new_messages : string Js.Dict.t
  ; current_room : Matrix.room option
  ; (* current_room : Matrix.room option; *)
    matrix_client : Matrix.client ref
  }

let init matrix_client =
  { current_room = None; matrix_client; new_messages = Js.Dict.empty () (* current_room = None; *) }


let send_message_cmd client room_id message =
  let content : Matrix.event_content =
    [%bs.obj { body = message; msgtype = "m.room.message" }]
  in
  Tea_promise.result (client##sendMessage room_id content) sentMessage

let peek_room_cmd model room_id =
  Tea_promise.result (!(model.matrix_client)##peekInRoom room_id)
  peeked

let resolve_alias_cmd model room_alias =
  Tea_promise.result (!(model.matrix_client)##resolveRoomAlias room_alias)
  gotRoomId

let set_chat_room model = function
  | Matrix.Id room_id -> Tea.Cmd.msg (SetCurrentRoom room_id)
  | Alias room_alias -> resolve_alias_cmd model room_alias

let update model = function
  | GoTo _ ->
      (model, Tea.Cmd.none)
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
  | SaveMessage (room_id, message) ->
      Js.Dict.set model.new_messages room_id message ;
      (model, Tea.Cmd.none)
  | SendMessage (room_id, message) ->
      Js.Dict.set model.new_messages room_id "" ;
      let cmd = send_message_cmd !(model.matrix_client) room_id message in
      (model, cmd)
  | SentMessage (Tea.Result.Ok res) ->
      let () = Js.log res in
      (model, Tea.Cmd.none)
  | SentMessage (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)


let string_of_option = function Some str -> str | None -> ""

let on_ctrl_enter ?(key = "") msg =
  let open Tea.Html in
  onCB "keydown" key (fun ev ->
      match Js.Undefined.toOption ev##target with
      | None ->
          None
      | Some target ->
        ( match Js.Undefined.toOption target##value with
        | None ->
            None
        | Some value ->
            if ev##keyCode = 13 && [%raw {|ev.ctrlKey|}]
            then Some (msg value)
            else None ))


let get_messages room =
  (room##getLiveTimeline ())##getEvents ()
  |. Belt.Array.keep (fun _matrix_event ->
         [%raw {|_matrix_event.event.type|}] = "m.room.message")


let message_view matrix_event =
  (* Js.log matrix_event; *)
  let open Tea.Html in
  (* let message_display = *)
  (*   Printf.sprintf *)
  (*     "<%s> %s" *)
  (*     matrix_event##sender##rawDisplayName *)
  (*     matrix_event##event##content##body *)
  (* in *)
  let date = Js.Date.fromFloat matrix_event##event##origin_server_ts in
  let iso_date = Js.Date.toISOString date in

  div [class' "message"; id matrix_event##event##event_id]
    [ div [class' "message-metadata"]
        [ span [class' "message-sender"] [text matrix_event##sender##rawDisplayName]
        ; time [class' "message-date"; Vdom.prop "datetime" iso_date ] [text
        (T.chat_message_date {date = date}) ]
        ]
    ; div [class' "message-body"] [text matrix_event##event##content##body]
    ]


let input_area model room_id =
  let open Tea.Html in
  let new_message_value model room_id =
    Js.Dict.get model.new_messages room_id |> string_of_option
  in
  textarea
    [ value (new_message_value model room_id)
    ; on_ctrl_enter ~key:room_id (sendMessage room_id)
    ; onInput ~key:room_id (saveMessage room_id)
    ]
    [ text "" ]


let view model =
  let open Tea.Html in
  match model.current_room with
  | Some room ->
      let message_list =
        get_messages room |. Belt.Array.map message_view |> Belt.List.fromArray
      in
      div
        ~unique:"chat"
        [ id "chat-view" ]
        [ h3 [] [text room##name]
        ; div ~unique:room##roomId [ id "message-list" ] message_list
        ; div ~unique:room##roomId [ id "input-area" ] [ input_area model
        room##roomId ]
        ]
  | None ->
      div [ id "room-view" ] [ text (T.chat_room_not_found ()) ]

(* let view model = function *)
(*   | Router.Room _ -> *)
(*       match model.current_room with *)
(*       | Some room -> room_view room (Js.Dict.get model.new_messages room##roomId |> *)
(*       string_of_option) *)
(*       | None -> Tea.Html.div [] [] *)
