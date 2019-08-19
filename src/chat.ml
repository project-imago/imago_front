type msg =
  | Login of (Matrix.login_response, string) Tea.Result.t
  | GetJoinedRooms of (Matrix.room_id list, string) Tea.Result.t
  | GoTo of Router.route
  | Info of (unit list, string) Tea.Result.t
  | RestoreCredentials of (string list, string) Tea.Result.t
  [@@bs.deriving {accessors}]

type model =
  {
    client : Matrix.client;
    matrix_id : string option;
    joined_rooms_ids : Matrix.room_id list;
  }

let try_login client =
  Tea_promise.result (Matrix.login client) login

let try_restore =
  [
    Tea.Ex.LocalStorage.getItem "access_token";
    Tea.Ex.LocalStorage.getItem "matrix_id";
  ]
  |> Tea_task.sequence
  |> Tea_task.attempt restoreCredentials 

let init = 
  let client = Matrix.new_client () in
  let model =
    {
      client;
      matrix_id = None;
      joined_rooms_ids = [];
    } in
  let cmd = try_restore in
  model, cmd

let update model = function
  | GetJoinedRooms (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let model = {model with joined_rooms_ids = res} in
      model, Tea.Cmd.none
  | GetJoinedRooms (Tea.Result.Error err) -> 
      let () = Js.log ("get joined rooms failed: " ^ err) in
      model, Tea.Cmd.none
  | Login (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let model = {model with matrix_id = Some res##user_id} in
      let save_cmd =
        [
          Tea.Ex.LocalStorage.setItem "access_token" res##access_token;
          Tea.Ex.LocalStorage.setItem "matrix_id" res##user_id;
        ]
        |> Tea_task.sequence
        |> Tea_task.attempt info in
      let get_rooms_cmd = Tea_promise.result (Matrix.get_joined_rooms model.client)
      getJoinedRooms in
      model, Tea.Cmd.batch [save_cmd; get_rooms_cmd]
  | Login (Tea.Result.Error err) -> 
      let () = Js.log ("login failed: " ^ err) in
      model, Tea.Cmd.none
  | GoTo _ ->
      model, Tea.Cmd.none
  | Info (Tea.Result.Ok _) -> Js.log "info"; model, Tea.Cmd.none
  | Info (Tea.Result.Error err) -> Js.log err; model, Tea.Cmd.none
  | RestoreCredentials (Tea.Result.Ok [access_token; matrix_id]) ->
      Js.log "restore token successful";
      let client = Matrix.new_client_params matrix_id access_token in
      {model with client; matrix_id = Some matrix_id},
      Tea_promise.result (Matrix.get_joined_rooms client) getJoinedRooms
  | RestoreCredentials (Tea.Result.Ok _) ->
      model, Tea.Cmd.msg (GoTo Index)
  | RestoreCredentials (Tea.Result.Error err) ->
      Js.log ("restore token failed: " ^ err);
      model, Tea.Cmd.msg (GoTo Index)
      
let room_list_view model =
  let open Tea.Html in
    ul
      []
      (Belt.List.map model.joined_rooms_ids (fun room_id ->
        li [] [button [ onClick (GoTo (Room room_id))] [text room_id]]))
