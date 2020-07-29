type msg =
  | GoTo of Router.route
  | SaveMessage of Matrix.room_id * string
  | SendMessage of Matrix.room_id * string
  | Info of (string, string) Tea.Result.t
[@@bs.deriving { accessors }]

type model =
  { new_messages : string Js.Dict.t
  ; (* current_room : Matrix.room option; *)
    matrix_client : Matrix.client ref
  }

let init matrix_client =
  { matrix_client; new_messages = Js.Dict.empty () (* current_room = None; *) }


let send_message_cmd client room_id message =
  let content : Matrix.event_content =
    [%bs.obj { body = message; msgtype = "m.room.message" }]
  in
  Tea_promise.result (client##sendMessage room_id content) info


let update model = function
  | GoTo _ ->
      (model, Tea.Cmd.none)
  | SaveMessage (room_id, message) ->
      Js.Dict.set model.new_messages room_id message ;
      (model, Tea.Cmd.none)
  | SendMessage (room_id, message) ->
      Js.Dict.set model.new_messages room_id "" ;
      let cmd = send_message_cmd !(model.matrix_client) room_id message in
      (model, cmd)
  | Info (Tea.Result.Ok res) ->
      let () = Js.log res in
      (model, Tea.Cmd.none)
  | Info (Tea.Result.Error err) ->
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

  div [class' "message"]
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


let view model room_id =
  let open Tea.Html in
  match !(model.matrix_client)##store##rooms |. Js.Dict.get room_id with
  | Some room ->
      let message_list =
        get_messages room |. Belt.Array.map message_view |> Belt.List.fromArray
      in
      div
        ~unique:"chat"
        [ id "chat-view" ]
        [ h3 [] [text room##name]
        ; div ~unique:room_id [ id "message-list" ] message_list
        ; div ~unique:room_id [ id "input-area" ] [ input_area model room_id ]
        ]
  | None ->
      div [ id "room-view" ] [ text (T.chat_room_not_found ()) ]

(* let view model = function *)
(*   | Router.Room _ -> *)
(*       match model.current_room with *)
(*       | Some room -> room_view room (Js.Dict.get model.new_messages room##roomId |> *)
(*       string_of_option) *)
(*       | None -> Tea.Html.div [] [] *)
