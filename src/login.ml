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
  | LoggedIn of (Matrix.login_response * string, string) Tea.Result.t
  | ListInfo of (unit list, string) Tea.Result.t
  | GotClientConfig of (Matrix.client_config * string, string) Tea.Result.t
[@@bs.deriving { accessors }]

let login_cmd model =
  Matrix.Client.login_with_password
    !(model.matrix_client)
    model.username
    model.password
  |> Js.Promise.then_ (fun res -> Js.Promise.resolve (res, Config.matrix_url))
  |. Tea_promise.result loggedIn


let login_to_remote_server_cmd model localpart domain =
  model.matrix_client := Matrix.create_client_to_server domain ;
  Matrix.Client.login_with_password
    !(model.matrix_client)
    localpart
    model.password
  |> Js.Promise.then_ (fun res -> Js.Promise.resolve (res, domain))
  |. Tea_promise.result loggedIn


let save_cmd login_response homeserver =
  [ Tea.Ex.LocalStorage.setItem "access_token" login_response##access_token
  ; Tea.Ex.LocalStorage.setItem "matrix_id" login_response##user_id
  ; Tea.Ex.LocalStorage.setItem "home_server" homeserver
    (* login_response##home_server *)
    (* can't do that because synapse strips the port from the homeserver url *)
  ]
  |> Tea_task.sequence
  |> Tea_task.attempt listInfo


type username =
  | Local of string
  | Remote of string * string

let parse_username username =
  let regex = [%re "/@([a-z0-9\.\_\=\-\/]+)\:([a-z0-9\.\-]+)/"] in
  (* Js.log (Js.String.match_ regex model.username); *)
  match Js.String.match_ regex username with
  | Some [| _; localpart; domain |] ->
      Remote (localpart, domain)
  | _ ->
      (* FIXME also test for invalid chararacters *)
      Local username


let find_remote_config_cmd model localpart domain =
  Matrixclient.matrixcs##_AutoDiscovery##findClientConfig domain
  |> Js.Promise.then_ (fun res -> Js.Promise.resolve (res, localpart))
  |. Tea_promise.result gotClientConfig


let update model = function
  | SaveUserName username ->
      ({ model with username }, Tea.Cmd.none)
  | SavePassword password ->
      ({ model with password }, Tea.Cmd.none)
  | Login ->
      let cmd =
        match parse_username model.username with
        | Remote (localpart, domain) ->
            find_remote_config_cmd model localpart domain
        | Local _ ->
            login_cmd model
      in
      (model, cmd)
  | LoggedIn (Tea.Result.Ok (res, homeserver)) ->
      let () = Js.log res in
      let () = Matrix.Client.start_client !(model.matrix_client) in
      ( model
      , Tea.Cmd.batch [ Tea.Cmd.msg (GoTo Index); save_cmd res homeserver ] )
  | LoggedIn (Tea.Result.Error err) ->
      let () = Js.log ("login failed: " ^ err) in
      (model, Tea.Cmd.none)
  | ListInfo (Tea.Result.Ok res) ->
      let () = Js.log res in
      (model, Tea.Cmd.none)
  | ListInfo (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)
  | GotClientConfig (Tea.Result.Ok (client_config, localpart)) ->
      let open Tablecloth.Option in
      let () = Js.log client_config in
      let homeserver_url =
        Js.Dict.get client_config "m.homeserver"
        |> map ~f:(fun config_part -> config_part##base_url)
        |> andThen ~f:Js.Nullable.toOption
      in
      let cmd =
        match homeserver_url with
        | Some url ->
            login_to_remote_server_cmd model localpart url
        | None ->
            Tea.Cmd.none
      in
      (* |> Tablecloth.Option.get_exn *)
      (model, cmd)
  | GotClientConfig (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)
  | GoTo _ ->
      (* this should never match *)
      (model, Tea.Cmd.none)


let view model =
  let open Tea.Html in
  form
    ~unique:"login"
    [ id "login"; Tea.Html2.Events.onSubmit login ]
    [ fieldset
        []
        [ label [ for' "username-field" ] [ text (T.login_username_label ()) ]
        ; input'
            [ type' "text"; id "username-field"; onInput saveUserName ]
            [ text model.username ]
        ; label [ for' "password-field" ] [ text (T.login_password_label ()) ]
        ; input'
            [ type' "password"; id "password-field"; onInput savePassword ]
            [ text model.password ]
        ; button [ type' "submit" ] [ text (T.login_submit ()) ]
        ]
    ; p
        []
        [ text (T.login_no_account_yet ())
        ; Router.link
            ~props:[ class' "button" ]
            goTo
            Signup
            [ text (T.login_register_button ()) ]
        ]
    ]
