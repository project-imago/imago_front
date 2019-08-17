open Tea.App
open Tea.Html

type msg =
  | Login of (Matrix.login_response, string) Tea.Result.t
  [@@bs.deriving {accessors}]

type model =
  {
    client : Matrix.client;
    matrix_id : string option
  }

let init () =
  Js.log "init";
  let client = Matrix.new_client () in
  let model = { client ; matrix_id = None } in
  let cmd = Tea_promise.result (Matrix.login client) login in
  model, cmd

let update model = function
  | Login (Tea.Result.Ok res) -> 
      Js.log res;
    {model with matrix_id = Some res##user_id}, Tea.Cmd.none
  | Login (Tea.Result.Error err) -> 
      Js.log err;
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
