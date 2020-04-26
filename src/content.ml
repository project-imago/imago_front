type model =
  {
    matrix_client : Matrix.client ref;
    room : Room.model;
    login : Login.model;
    signup : Signup.model;
    create_group : Create_group.model;
  }

type msg =
  | RoomMsg of Room.msg
  | LoginMsg of Login.msg
  | SignupMsg of Signup.msg
  | CreateGroupMsg of Create_group.msg
  | GoTo of Router.route
  [@@bs.deriving {accessors}]

let msg_to_string = function
  | RoomMsg msg -> "room msg" (*Room.msg_to_string msg*)
  | LoginMsg msg -> "login msg" (*Login.msg_to_string msg*)
  | SignupMsg msg -> Signup.msg_to_string msg
  | CreateGroupMsg msg -> "create group msg" (*CreateGroup.msg_to_string msg*)
  | GoTo msg -> "goto"

let init matrix_client = 
  {
    matrix_client;
    room = Room.init matrix_client;
    login = Login.init matrix_client;
    signup = Signup.init matrix_client;
    create_group = Create_group.init matrix_client;
  }

let update model = function
  | RoomMsg room_msg ->
      let room, room_cmd = Room.update model.room room_msg in
      {model with room},
      Tea.Cmd.map roomMsg room_cmd
  | CreateGroupMsg create_group_msg ->
      let create_group, create_group_cmd = Create_group.update
      model.create_group create_group_msg in
      {model with create_group},
      Tea.Cmd.map createGroupMsg create_group_cmd
  | LoginMsg (GoTo route) -> model, Tea.Cmd.msg (GoTo route)
  | LoginMsg login_msg ->
      let login, login_cmd = Login.update model.login login_msg in
      {model with login},
      Tea.Cmd.map loginMsg login_cmd
  | GoTo route ->
      model, Tea.Cmd.none
  | SignupMsg (GoTo route) -> model, Tea.Cmd.msg (GoTo route)
  | SignupMsg signup_msg ->
      let signup, signup_cmd = Signup.update model.signup signup_msg in
      {model with signup},
      Tea.Cmd.map signupMsg signup_cmd

let logged_out_index_view model =
  let open Tea.Html in
  div []
  [
    text "Welcome";
    button [ onClick (GoTo Login)] [text "Login"];
    button [ onClick (GoTo Signup)] [text "Signup"];
  ]

let logged_in_index_view model =
  let open Tea.Html in
  div []
  [ text "Welcome"; ]

let index_view model =
  if !(model.matrix_client)##isLoggedIn () then
    logged_in_index_view model
  else
    logged_out_index_view model

let view (route : Router.route) model =
  let open Tea.Html in
  (* let is_logged_in = !(model.matrix_client)##isLoggedIn () in *)
  div [ id "content" ]
  [
    match route with
    | Index -> index_view model
    | Login -> Login.view model.login |> Vdom.map loginMsg
    | Signup -> Signup.view model.signup |> Vdom.map signupMsg
    | Logout -> div [] []
    | CreateGroup -> Create_group.view model.create_group |> Vdom.map
    createGroupMsg
    | Room room_id -> Room.view model.room room_id |> Vdom.map roomMsg
  ]

