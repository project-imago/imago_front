type msg =
  | LoggedIn of (Matrix.login_response, string) Tea.Result.t
  | GetJoinedRooms of (Matrix.room_id list, string) Tea.Result.t
  | GoTo of Router.route
  | Info of (unit list, string) Tea.Result.t
  | RestoredCredentials of ((Matrix.client * Matrix.access_token * Matrix.user_id), string) Tea.Result.t
  | GotMessage of Matrix.event
  [@@bs.deriving {accessors}]

type model =
  {
    client : Matrix.client;
    matrix_id : Matrix.user_id option;
    access_token : Matrix.access_token option;
    joined_rooms_ids : Matrix.room_id list;
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

let get_joined_rooms_cmd client =
  Tea_promise.result (Matrix.get_joined_rooms client) getJoinedRooms
  
let restore_cmd =
  Js.log "init chat";
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
        | _, _ -> Tea_task.fail "LocalStorage error")
      | _ -> Tea_task.fail "LocalStorage error"
  )
  |> Tea_task.andThen (fun (access_token, matrix_id) ->
      Js.log access_token;
      let client = Matrix.new_client_params matrix_id access_token in
      (client, access_token, matrix_id)
      |> Tea_task.succeed)
  |> Tea_task.attempt restoredCredentials

let save_cmd access_token matrix_id =
  [ Tea.Ex.LocalStorage.setItem "access_token" access_token;
    Tea.Ex.LocalStorage.setItem "matrix_id" matrix_id; ]
  |> Tea_task.sequence
  |> Tea_task.attempt info

let init = 
  let client = Matrix.new_client () in
  let model =
    {
      client;
      matrix_id = None;
      access_token = None;
      joined_rooms_ids = [];
    } in
  let cmd = restore_cmd in
  model, cmd

let update model = function
  | RestoredCredentials (Tea.Result.Ok (client, access_token, matrix_id)) ->
      let model =
        { model with client;
          access_token = Some access_token;
          matrix_id = Some matrix_id } in
      model, get_joined_rooms_cmd model.client
  | RestoredCredentials (Tea.Result.Error err) ->
      Js.log ("restore failed: " ^ err);
      model, login_cmd model.client
  | LoggedIn (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let model =
        { model with
          matrix_id = Some res##user_id;
          access_token = Some res##access_token } in
      model, Tea.Cmd.batch [save_cmd res##access_token res##user_id;
      get_joined_rooms_cmd model.client]
  | LoggedIn (Tea.Result.Error err) -> 
      let () = Js.log ("login failed: " ^ err) in
      model, Tea.Cmd.none
  | GetJoinedRooms (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let () = Js.log "got joined rooms, start client" in
      let () = Matrix.start_client model.client in
      let model = {model with joined_rooms_ids = res} in
      model, Tea.Cmd.none
  | GetJoinedRooms (Tea.Result.Error err) -> 
      let () = Js.log ("get joined rooms failed: " ^ err) in
      model, Tea.Cmd.none
  | GoTo _ ->
      model, Tea.Cmd.none
  | Info (Tea.Result.Ok _) -> Js.log "info"; model, Tea.Cmd.none
  | Info (Tea.Result.Error err) -> Js.log err; model, Tea.Cmd.none
  | GotMessage event -> Js.log event; model, Tea.Cmd.none
      
let room_list_view model =
      (*let () = Matrix.once model.client (`sync (fun a b c -> Js.log (a, b, c)))
      |> Js.log
      in *)
  let open Tea.Html in
    ul
      []
      (Belt.List.map model.joined_rooms_ids (fun room_id ->
        li [] [button [ onClick (GoTo (Room room_id))] [text room_id]]))

let room_view model room_id =
  Js.log room_id;
  Js.log model.client##store##rooms;
  let open Tea.Html in
  match (model.client##store##rooms |. Js.Dict.get room_id) with
  | None -> div [] []
  | Some room ->
      let message_list =
        let () = Js.log room##timeline in
        let filtered = room##timeline
        |> Tablecloth.Array.filter ~f:(fun matrix_event ->
            [%raw {|matrix_event.event.type|}] = "m.room.message")
        in
        let _ = Js.log filtered in
      filtered
        |> Tablecloth.Array.map ~f:(fun matrix_event -> div [] [ text (Printf.sprintf
        "<%s> %s" matrix_event##event##sender matrix_event##event##content##body) ])
        |> Tablecloth.Array.to_list
      in
      div [] message_list


let subscriptions model =
  match model.matrix_id with
  | Some _ -> Matrix.subscribe model.client gotMessage
  | None -> Tea.Sub.none

