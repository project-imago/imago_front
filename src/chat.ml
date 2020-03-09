

type msg =
  | LoggedIn of (Matrix.login_response, string) Tea.Result.t
  | GoTo of Router.route
  | Info of (string, string) Tea.Result.t
  | ListInfo of (unit list, string) Tea.Result.t
  | RestoredSession of (Matrix.client, string) Tea.Result.t
  | GotMessage of Matrix.event
  | SaveMessage of string
  | SendMessage of string
  | Sync of string
  [@@bs.deriving {accessors}]

type model =
  {
    client : Matrix.client;
    new_messages : string Js.Dict.t;
    current_room : Matrix.room option;
  }

let promiseToTask promise =
  let open Tea_task in
  nativeBinding (fun cb ->
      let _ = promise
              |> Js.Promise.then_ (function res ->
                  let resolve = cb (Tea_result.Ok res) in
                  Js.Promise.resolve resolve
                )
              |> Js.Promise.catch (function err ->
                  let err_to_string err =
                    {j|$err|j} in
                  let reject = cb (Tea_result.Error (err_to_string err)) in
                  Js.Promise.resolve reject
                )
      in
      ()
    )

let login_cmd client =
  Tea_promise.result (Matrix.login client) loggedIn

let restore_cmd =
  [
    Tea.Ex.LocalStorage.getItem "access_token";
    Tea.Ex.LocalStorage.getItem "matrix_id";
  ]
  |> Tea_task.sequence
  |> Tea_task.andThen (function
    | [nullable_access_token; nullable_matrix_id] ->
        let access_token =
          nullable_access_token
          |> Js.Nullable.return
          |> Js.Nullable.toOption in
        let matrix_id =
          nullable_matrix_id
          |> Js.Nullable.return
          |> Js.Nullable.toOption in
        (match access_token, matrix_id with
        | Some a, Some b -> Tea_task.succeed (a, b)
        | _, _ -> Tea_task.fail "Not in LocalStorage")
      | _ -> Tea_task.fail "Not in LocalStorage"
  )
  |> Tea_task.andThen (fun (access_token, matrix_id) ->
      let client = Matrix.new_client_params matrix_id access_token in
      Tea_task.succeed client)
  |> Tea_task.attempt restoredSession

let save_cmd client =
  [ Tea.Ex.LocalStorage.setItem "access_token" (client##getAccessToken ());
    Tea.Ex.LocalStorage.setItem "matrix_id" client##credentials##userId; ]
  |> Tea_task.sequence
  |> Tea_task.attempt listInfo

let send_message_cmd client room_id message =
  let content : Matrix.event_content =
    [%bs.obj
      { body =    message;
        msgtype = "m.room.message";
      }] in
  Tea_promise.result (client##sendMessage room_id content) info

let init = 
  let client = Matrix.new_client () in
  let model =
    { client;
      new_messages = Js.Dict.empty ();
      current_room = None;
    } in
  let cmd = restore_cmd in
  model, cmd

let update_route model = function
  | Router.Room room_id as route ->
      match (model.client##store##rooms |. Js.Dict.get room_id) with
      | Some room ->
          let model = {model with current_room = Some room } in
          model, Router.ChatRoute route
      | None -> 
          { model with current_room = None }, Router.Index

let reset_route model =
  {model with current_room = None}

let update model = function
  | RestoredSession (Tea.Result.Ok (client)) ->
      let model = { model with client } in
      let () = Matrix.start_client model.client in
      model, Tea.Cmd.none
  | RestoredSession (Tea.Result.Error err) ->
      let () = Js.log ("restore failed: " ^ err) in
      model, login_cmd model.client
  | LoggedIn (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let () = Matrix.start_client model.client in
      model, save_cmd model.client
  | LoggedIn (Tea.Result.Error err) -> 
      let () = Js.log ("login failed: " ^ err) in
      model, Tea.Cmd.none
  | GoTo _ ->
      model, Tea.Cmd.none
  | Info (Tea.Result.Ok res) ->
      let () = Js.log res in
      model, Tea.Cmd.none
  | Info (Tea.Result.Error err) ->
      let () = Js.log err in
      model, Tea.Cmd.none
  | ListInfo (Tea.Result.Ok res) ->
      let () = Js.log res in
      model, Tea.Cmd.none
  | ListInfo (Tea.Result.Error err) ->
      let () = Js.log err in
      model, Tea.Cmd.none
  | GotMessage event ->
      let () = Js.log event in
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
          send_message_cmd model.client room##roomId message
      | None ->
          Tea.Cmd.none in
      model, cmd
  | Sync state ->
      let () = Js.log state in
      model, Tea.Cmd.none

let equal_to_option value = function
  | None -> false
  | Some v -> v = value

let room_list_view model =
  let open Tea.Html in
  let rooms = Js.Dict.values model.client##store##rooms in
    ul
      []
      (rooms
      |. Belt.Array.map (fun room ->
          let room_name_text =
            if equal_to_option room model.current_room then
              b [] [text room##name]
            else
              text room##name in
        li [] [button [ onClick (GoTo (ChatRoute (Room room##roomId)))]
        [room_name_text]])
      |> Belt.List.fromArray)

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
    
let string_of_option = function
  | Some str -> str
  | None -> ""

let get_messages room =
  (room##getLiveTimeline ())##getEvents ()
  |. Belt.Array.keep (fun matrix_event ->
      [%raw {|matrix_event.event.type|}] = "m.room.message")

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

let room_view room new_message =
  let open Tea.Html in
  let message_list =
    get_messages room
    |. Belt.Array.map message_view
    |> Belt.List.fromArray in
  let input_area =
    textarea
      [class' room##roomId;
       value new_message;
       on_ctrl_enter sendMessage;
       onInput saveMessage]
      [] in
  div
    [ id "room-view" ]
    [div [ id "message-list" ] message_list;
     div [ id "input-area" ] [input_area]]

let view model = function
  | Router.Room _ ->
      match model.current_room with
      | Some room -> room_view room (Js.Dict.get model.new_messages room##roomId |>
      string_of_option)
      | None -> Tea.Html.div [] []

let subscriptions model =
  match model.client##clientRunning with
  | true -> Tea.Sub.batch [Matrix.subscribe model.client gotMessage;
  Matrix.subscribe_once model.client sync]
  | false -> Tea.Sub.none
