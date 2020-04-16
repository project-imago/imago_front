

type msg =
  | LoggedIn of (Matrix.login_response, string) Tea.Result.t
  | GoTo of Router.route
  | Info of (string, string) Tea.Result.t
  | ListInfo of (unit list, string) Tea.Result.t
  | RestoredSession of (Matrix.client, string) Tea.Result.t
  | GotMessage of Matrix.event
  | Sync of string
  [@@bs.deriving {accessors}]

let msg_to_string (msg : msg) =
  match msg with
  | LoggedIn _ -> "logged in"
  | GoTo _ -> "go to"
  | Info _ -> "info"
  | ListInfo _ -> "list info"
  | RestoredSession _ -> "restored session"
  | GotMessage _ -> "got msg"
  | Sync _ -> "sync"


type model =
  {
    matrix_client : Matrix.client ref;
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

let init_cmd = restore_cmd

let init_model matrix_client =
  {
    matrix_client;
  }

(* let update_route model = function *)
(*   | Router.Room room_id as route -> *)
(*       match (model.client##store##rooms |. Js.Dict.get room_id) with *)
(*       | Some room -> *)
(*           let model = {model with current_room = Some room } in *)
(*           model, Router.ChatRoute route *)
(*       | None -> *) 
(*           { model with current_room = None }, Router.Index *)

let update model = function
  | RestoredSession (Tea.Result.Ok (client)) ->
      (model.matrix_client) := client;
      let () = Matrix.start_client !(model.matrix_client) in
      model, Tea.Cmd.none
  | RestoredSession (Tea.Result.Error err) ->
      let () = Js.log ("restore failed: " ^ err) in
      model, login_cmd !(model.matrix_client)
  | LoggedIn (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let () = Matrix.start_client !(model.matrix_client) in
      model, save_cmd !(model.matrix_client)
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
  | Sync state ->
      let () = Js.log state in
      model, Tea.Cmd.none

let subscriptions model =
  match !(model.matrix_client)##clientRunning with
  | true -> Tea.Sub.batch [Matrix.subscribe !(model.matrix_client) gotMessage;
  Matrix.subscribe_once !(model.matrix_client) sync]
  | false -> Tea.Sub.none
