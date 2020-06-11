

type msg =
  | GoTo of Router.route
  | Info of (string, string) Tea.Result.t
  | RestoredSession of (string * string, string) Tea.Result.t
  | GotMessage of Matrix.event
  | Sync of string
  | LoggedOut of string
[@@bs.deriving { accessors }]

let msg_to_string (msg : msg) =
  match msg with
  | GoTo _ ->
      "go to"
  | Info _ ->
      "info"
  | RestoredSession _ ->
      "restored session"
  | GotMessage _ ->
      "got msg"
  | Sync _ ->
      "sync"
  | LoggedOut _ ->
      "logged out"


type model = { matrix_client : Matrix.client ref }

let promiseToTask promise =
  let open Tea_task in
  nativeBinding (fun cb ->
      let _ =
        promise
        |> Js.Promise.then_ (function res ->
               let resolve = cb (Tea_result.Ok res) in
               Js.Promise.resolve resolve)
        |> Js.Promise.catch (function err ->
               let err_to_string err = {j|$err|j} in
               let reject = cb (Tea_result.Error (err_to_string err)) in
               Js.Promise.resolve reject)
      in
      ())


let restore_cmd _matrix_client =
  [ Tea.Ex.LocalStorage.getItem "access_token"
  ; Tea.Ex.LocalStorage.getItem "matrix_id"
  ]
  |> Tea_task.sequence
  |> Tea_task.andThen (function
         | [ nullable_access_token; nullable_matrix_id ] ->
             let access_token =
               nullable_access_token
               |> Js.Nullable.return
               |> Js.Nullable.toOption
             in
             let matrix_id =
               nullable_matrix_id |> Js.Nullable.return |> Js.Nullable.toOption
             in
             ( match (access_token, matrix_id) with
             | Some a, Some b ->
                 Tea_task.succeed (a, b)
             | _, _ ->
                 Tea_task.fail "Not in LocalStorage" )
         | _ ->
             Tea_task.fail "Not in LocalStorage")
  |> Tea_task.andThen (fun (access_token, matrix_id) ->
         (* let client = Matrix.new_client_params matrix_id access_token in *)
         Tea_task.succeed (access_token, matrix_id))
  |> Tea_task.attempt restoredSession


let remove_storage_cmd : msg Tea.Cmd.t =
  Tea.Cmd.batch
    [ Tea.Ex.LocalStorage.removeItemCmd "access_token"
    ; Tea.Ex.LocalStorage.removeItemCmd "matrix_id"
    ]

let subscriptions model =
  (* let () = Js.log "chat subs" in *)
  match !(model.matrix_client)##clientRunning with
  | true ->
      Tea.Sub.batch
        [ Matrix.Client.subscribe !(model.matrix_client) gotMessage
        ; Matrix.Client.subscribe_once_logged_out !(model.matrix_client) loggedOut
          (* ; Matrix.subscribe_once !(model.matrix_client) sync *)
          (* TODO: move so it's really once *)
        ]
  | false ->
      Tea.Sub.none

let login_with_password (matrix_client : Matrix.client ref) username password =
  Matrix.Client.login_with_password !matrix_client username password |> ignore


let login_with_token (matrix_client : Matrix.client ref) token =
  Matrix.Client.login_with_password !matrix_client token |> ignore


let logout (matrix_client : Matrix.client ref) =
  let _ = Matrix.Client.logout !matrix_client in
  let () = Matrix.Client.stop_client !matrix_client in
  matrix_client := Matrix.create_client ();
  remove_storage_cmd


let is_logged_in (matrix_client : Matrix.client ref) =
  !matrix_client##isLoggedIn ()


let user_id (matrix_client : Matrix.client ref) =
  !matrix_client##credentials##userId


(* let init_cmd = restore_cmd *)

let init matrix_client = ({ matrix_client }, restore_cmd matrix_client)

(* let update_route model = function *)
(*   | Router.Room room_id as route -> *)
(*       match (model.client##store##rooms |. Js.Dict.get room_id) with *)
(*       | Some room -> *)
(*           let model = {model with current_room = Some room } in *)
(*           model, Router.ChatRoute route *)
(*       | None -> *)
(*           { model with current_room = None }, Router.Index *)

let update model = function
  | RestoredSession (Tea.Result.Ok (access_token, matrix_id)) ->
      let () = Js.log "restored access token" in
      model.matrix_client := Matrix.new_client_params matrix_id access_token ;
      let () = Matrix.Client.start_client !(model.matrix_client) in
      (model, Tea.Cmd.none)
  | RestoredSession (Tea.Result.Error err) ->
      let () = Js.log ("restore failed: " ^ err) in
      (model, Tea.Cmd.none)
  | GoTo _ ->
      (model, Tea.Cmd.none)
  | Info (Tea.Result.Ok res) ->
      let () = Js.log res in
      (model, Tea.Cmd.none)
  | Info (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)
  | GotMessage event ->
      (* let () = Js.log event in *)
      (model, Tea.Cmd.none)
  | Sync _state ->
      (* let () = Js.log state in *)
      (model, Tea.Cmd.none)
  | LoggedOut state ->
      let () = Js.log state in
      let cmd = logout model.matrix_client in
      (model, cmd)

