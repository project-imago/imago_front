

type msg =
  | LoggedIn of (Matrix.login_response, string) Tea.Result.t
  | GoTo of Router.route
  | Info of (string, string) Tea.Result.t
  | ListInfo of (unit list, string) Tea.Result.t
  | RestoredSession of (Matrix.client, string) Tea.Result.t
  | GotMessage of Matrix.event
  | SaveMessage of string * Matrix.room_id
  | SendMessage of string * Matrix.room_id
  | Sync of string
  [@@bs.deriving {accessors}]

type model =
  {
    client : Matrix.client;
    new_message : string;
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
  Js.log room_id; Js.log message;
  let content : Matrix.event_content = [%bs.obj { body = message; msgtype =
    "m.room.message" }] in
  Tea_promise.result (client##sendMessage room_id content) info

let init = 
  let client = Matrix.new_client () in
  let model =
    {
      client;
      new_message = "";
    } in
  let cmd = restore_cmd in
  model, cmd

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
  | SaveMessage (room_id, message) ->
      let model = { model with new_message = message} in
      model, Tea.Cmd.none
  | SendMessage (room_id, message) ->
      let model = { model with new_message = ""} in
      model, send_message_cmd model.client room_id message
  | Sync state ->
      let () = Js.log state in
      model, Tea.Cmd.none
      
let room_list_view model =
  let open Tea.Html in
  let rooms = Js.Dict.values model.client##store##rooms in
    ul
      []
      (rooms
      |> Tablecloth.Array.map ~f:(fun room ->
          Js.log room;
        li [] [button [ onClick (GoTo (Room room##roomId))] [text room##name]])
      |> Tablecloth.Array.to_list)

let on_input_save_or_send ?(key="") save_msg send_msg =
  let open Tea.Html in
  onCB "keydown" key
    (fun ev ->
      Js.log ev;
       match Js.Undefined.toOption ev##target with
       | None -> None
       | Some target -> match Js.Undefined.toOption target##value with
         | None -> None
         | Some value ->
             if ev##keyCode = 13 && [%raw {|ev.ctrlKey|}] then
               Some (send_msg value)
             else
               Some (save_msg value)
    )

let room_view model room_id =
  let open Tea.Html in
  match (model.client##store##rooms |. Js.Dict.get room_id) with
  | None -> div [] []
  | Some room ->
      Js.log room##timeline;
      let message_list =
        room##timeline
        |> Tablecloth.Array.filter ~f:(fun matrix_event ->
            [%raw {|matrix_event.event.type|}] = "m.room.message")
        |> Tablecloth.Array.map ~f:(fun matrix_event ->
            div
              [style "white-space" "pre"]
              [ text (Printf.sprintf
                        "<%s> %s"
                        matrix_event##sender##rawDisplayName
                        matrix_event##event##content##body
        ) ])
        |> Tablecloth.Array.to_list in
      let input_area =
        textarea [value model.new_message; on_input_save_or_send (saveMessage
        room_id) (sendMessage room_id)] [] in
      div [] [div [] message_list; div [] [input_area]]


let subscriptions model =
  match model.client##clientRunning with
  | true -> Tea.Sub.batch [Matrix.subscribe model.client gotMessage;
  Matrix.subscribe_once model.client sync]
  | false -> Tea.Sub.none
