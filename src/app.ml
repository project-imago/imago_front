open Tea.App
open Tea.Html

type msg =
  | Login of (Matrix.login_response, string) Tea.Result.t
  | GetJoinedRooms of (Matrix.room_id list, string) Tea.Result.t
  [@@bs.deriving {accessors}]

type model =
  {
    client : Matrix.client;
    matrix_id : string option;
    joined_rooms_ids : Matrix.room_id list
  }

let init () =
  Js.log "init";
  let client = Matrix.new_client () in
  let model =
    { client
    ; matrix_id = None
    ; joined_rooms_ids = []
    } in
  let cmd = Tea_promise.result (Matrix.login client) login in
  model, cmd

let update model = function
  | GetJoinedRooms (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let model = {model with joined_rooms_ids = res} in
      model, Tea.Cmd.none
  | GetJoinedRooms (Tea.Result.Error err) -> 
      let () = Js.log err in
      model, Tea.Cmd.none
  | Login (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let model = {model with matrix_id = Some res##user_id} in
      let cmd = Tea_promise.result (Matrix.get_joined_rooms model.client)
      getJoinedRooms in
      model, cmd
  | Login (Tea.Result.Error err) -> 
      let () = Js.log err in
      model, Tea.Cmd.none

let view model =
  div
    []
    [ span
        [ style "text-weight" "bold" ]
        [ text (match model.matrix_id with Some str -> str | None ->
          "disconnected") ]
    ]

let main =
  standardProgram {
    init;
    update;
    view;
    subscriptions = (fun _ -> Tea.Sub.none);
  }
