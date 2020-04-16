type model =
  {
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
  [@@bs.deriving {accessors}]

let msg_to_string _msg = "content msg"

let init matrix_client = 
  {
    room = Room.init matrix_client;
    login = Login.init matrix_client;
    signup = Signup.init matrix_client;
    create_group = Create_group.init matrix_client;
  }

let view (route : Router.route) model =
  let open Tea.Html in
  div [ id "content" ]
  [
    match route with
    | Index -> div [] [text "Welcome"]
    | Login -> Login.view model.login |> Vdom.map loginMsg
    | Signup -> Signup.view model.signup |> Vdom.map signupMsg
    | Logout -> div [] []
    | CreateGroup -> Create_group.view model.create_group |> Vdom.map loginMsg
    | Room room_id -> Room.view model.room room_id |> Vdom.map roomMsg
  ]

