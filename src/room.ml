type msg =
  | GoTo of Router.route
  | SaveMessage of string
  | SendMessage of string
  | Info of (string, string) Tea.Result.t
  [@@bs.deriving {accessors}]

type model =
  {
    new_messages : string Js.Dict.t;
    current_room : Matrix.room option;
    matrix_client : Matrix.client ref;
  }

let init matrix_client =
  {
      matrix_client;
      new_messages = Js.Dict.empty ();
      current_room = None;
  }

let send_message_cmd client room_id message =
  let content : Matrix.event_content =
    [%bs.obj
      { body =    message;
        msgtype = "m.room.message";
      }] in
  Tea_promise.result (client##sendMessage room_id content) info

let update model = function
  | GoTo _ ->
      model, Tea.Cmd.none
  | SaveMessage message ->
      let () = match model.current_room with
      | Some room ->
          Js.Dict.set model.new_messages room##roomId message
      | None ->
          () in
      model, Tea.Cmd.none
  | SendMessage message ->
      let cmd = match model.current_room with
      | Some room ->
          let () = Js.Dict.set model.new_messages room##roomId "" in
          send_message_cmd !(model.matrix_client) room##roomId message
      | None ->
          Tea.Cmd.none in
      model, cmd
  | Info (Tea.Result.Ok res) ->
      let () = Js.log res in
      model, Tea.Cmd.none
  | Info (Tea.Result.Error err) ->
      let () = Js.log err in
      model, Tea.Cmd.none
    
let string_of_option = function
  | Some str -> str
  | None -> ""

let on_ctrl_enter ?(key="") msg =
  let open Tea.Html in
  onCB "keydown" key
    (fun ev ->
       match Js.Undefined.toOption ev##target with
       | None -> None
       | Some target -> match Js.Undefined.toOption target##value with
         | None -> None
         | Some value ->
             if ev##keyCode = 13 && [%raw {|ev.ctrlKey|}] then
               Some (msg value)
             else
               None)

let get_messages room =
  (room##getLiveTimeline ())##getEvents ()
  |. Belt.Array.keep (fun _matrix_event ->
      [%raw {|_matrix_event.event.type|}] = "m.room.message")

let message_view matrix_event =
  let open Tea.Html in
  let message_display =
    Printf.sprintf
      "<%s> %s"
      matrix_event##sender##rawDisplayName
      matrix_event##event##content##body in
  div
    [style "white-space" "pre"]
    [text message_display]

let new_message_value model room = 
  Js.Dict.get model.new_messages room##roomId
  |> string_of_option


let view model room_id =
  let open Tea.Html in
  match (!(model.matrix_client)##store##rooms |. Js.Dict.get room_id) with
  | Some room ->
    let message_list =
      get_messages room
      |. Belt.Array.map message_view
      |> Belt.List.fromArray in
    let input_area =
      textarea
        [class' room##roomId;
         value (new_message_value model room);
         on_ctrl_enter sendMessage;
         onInput saveMessage]
        [] in
    div
      [ id "room-view" ]
      [div [ id "message-list" ] message_list;
       div [ id "input-area" ] [input_area]]
  | None ->
      div
        [ id "room-view" ]
        [text "room not found"]

(* let view model = function *)
(*   | Router.Room _ -> *)
(*       match model.current_room with *)
(*       | Some room -> room_view room (Js.Dict.get model.new_messages room##roomId |> *)
(*       string_of_option) *)
(*       | None -> Tea.Html.div [] [] *)

