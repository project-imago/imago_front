type model =
  {
    matrix_client : Matrix.client ref;
    username : string;
    password : string;
  }

let init matrix_client =
  {
      matrix_client;
      username = "";
      password = "";
  }

type msg =
  | GoTo of Router.route
  | SaveUserName of string
  | SavePassword of string
  | Login
  | LoggedIn of (Matrix.login_response, string) Tea.Result.t
  | ListInfo of (unit list, string) Tea.Result.t
  [@@bs.deriving {accessors}]

let login_cmd model =
  Tea_promise.result
    (Matrix.login_with_password !(model.matrix_client) model.username model.password)
    loggedIn

let save_cmd client =
  [ Tea.Ex.LocalStorage.setItem "access_token" (client##getAccessToken ());
    Tea.Ex.LocalStorage.setItem "matrix_id" client##credentials##userId; ]
  |> Tea_task.sequence
  |> Tea_task.attempt listInfo

let update model = function
  | SaveUserName username ->
      {model with username = username},
      Tea.Cmd.none
  | SavePassword password ->
      {model with password = password},
      Tea.Cmd.none
  | Login ->
      model, login_cmd model
  | LoggedIn (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let () = Matrix.start_client !(model.matrix_client) in
      model, Tea.Cmd.msg (GoTo Index) (*save_cmd !(model.matrix_client)*)
  | LoggedIn (Tea.Result.Error err) -> 
      let () = Js.log ("login failed: " ^ err) in
      model, Tea.Cmd.none
  | ListInfo (Tea.Result.Ok res) ->
      let () = Js.log res in
      model, Tea.Cmd.none
  | ListInfo (Tea.Result.Error err) ->
      let () = Js.log err in
      model, Tea.Cmd.none

let view model =
  let open Tea.Html in
  div []
  [
    input'
      [type' "text";
       onInput saveUserName]
      [text model.username];
    input'
      [type' "password";
       onInput savePassword]
      [text model.password];
    button
      [onClick login]
      [text "Login"]
  ]
