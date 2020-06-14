type model =
  { matrix_client : Matrix.client ref
  ; username : string
  ; password : string
  }

let init matrix_client = { matrix_client; username = ""; password = "" }

type msg =
  | GoTo of Router.route
  | SaveUserName of string
  | SavePassword of string
  | Login
  | LoggedIn of (Matrix.login_response, string) Tea.Result.t
  | ListInfo of (unit list, string) Tea.Result.t
[@@bs.deriving { accessors }]

let login_cmd model =
  Tea_promise.result
    (Matrix.Client.login_with_password
       !(model.matrix_client)
       model.username
       model.password)
    loggedIn

let login_to_server_cmd model localpart domain =
  model.matrix_client := Matrix.create_client_to_server domain;
  Tea_promise.result
    (Matrix.Client.login_with_password
       !(model.matrix_client)
       localpart
       model.password)
    loggedIn




let save_cmd login_response =
  [ Tea.Ex.LocalStorage.setItem "access_token" (login_response##access_token)
  ; Tea.Ex.LocalStorage.setItem "matrix_id" login_response##user_id
  ; Tea.Ex.LocalStorage.setItem "home_server" login_response##home_server
  ]
  |> Tea_task.sequence
  |> Tea_task.attempt listInfo


let update model = function
  | SaveUserName username ->
      ({ model with username }, Tea.Cmd.none)
  | SavePassword password ->
      ({ model with password }, Tea.Cmd.none)
  | Login ->
      let regex = [%re "/@([a-z0-9\.\_\=\-\/]+)\:([a-z0-9\.\-]+)/"] in
      Js.log (Js.String.match_ regex model.username);
      let cmd = 
        match Js.String.match_ regex model.username with
        | Some [| _; localpart; domain |] ->
            let domain = "https://" ^ domain in
            (* FIXME we sould get the real server from .well-known route *)
            login_to_server_cmd model localpart domain
        | _ -> (* FIXME also test for invalid chararacters *)
            login_cmd model
      in
      (model, cmd)
  | LoggedIn (Tea.Result.Ok res) ->
      let () = Js.log res in
      let () = Matrix.Client.start_client !(model.matrix_client) in
      ( model
      , Tea.Cmd.batch
          [ Tea.Cmd.msg (GoTo Index); save_cmd res ] )
  | LoggedIn (Tea.Result.Error err) ->
      let () = Js.log ("login failed: " ^ err) in
      (model, Tea.Cmd.none)
  | ListInfo (Tea.Result.Ok res) ->
      let () = Js.log res in
      (model, Tea.Cmd.none)
  | ListInfo (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)
  | GoTo _ ->
      (* this should never match *)
      (model, Tea.Cmd.none)


let view model =
  let open Tea.Html in
  form
    ~unique:"login"
    [ Tea.Html2.Events.onSubmit login ]
    [ fieldset
        []
        [ label [ for' "username-field" ] [ text "Username" ]
        ; input'
            [ type' "text"; id "username-field"; onInput saveUserName ]
            [ text model.username ]
        ; label [ for' "password-field" ] [ text "Password" ]
        ; input'
            [ type' "password"; id "password-field"; onInput savePassword ]
            [ text model.password ]
        ; button [ type' "submit" ] [ text "Login" ]
        ]
    ]
