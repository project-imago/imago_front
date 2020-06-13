type model =
  { matrix_client : Matrix.client ref
  ; chat : Chat.model
  ; group : Group.model
  ; login : Login.model
  ; signup : Signup.model
  ; create_group : Create_group.model
  ; create_chat : Create_chat.model
  }

type msg =
  | ChatMsg of Chat.msg
  | GroupMsg of Group.msg
  | LoginMsg of Login.msg
  | SignupMsg of Signup.msg
  | CreateGroupMsg of Create_group.msg
  | CreateChatMsg of Create_chat.msg
  | GoTo of Router.route
[@@bs.deriving { accessors }]

let msg_to_string = function
  | ChatMsg _msg ->
      "chat msg" (*Chat.msg_to_string msg*)
  | GroupMsg _msg ->
      "group msg" (*Chat.msg_to_string msg*)
  | LoginMsg _msg ->
      "login msg" (*Login.msg_to_string msg*)
  | SignupMsg msg ->
      Signup.msg_to_string msg
  | CreateGroupMsg _msg ->
      "create group msg" (*CreateGroup.msg_to_string msg*)
  | CreateChatMsg _msg ->
      "create chat msg"
  | GoTo _msg ->
      "goto"


let init matrix_client =
  { matrix_client
  ; chat = Chat.init matrix_client
  ; group = Group.init matrix_client
  ; login = Login.init matrix_client
  ; signup = Signup.init matrix_client
  ; create_group = Create_group.init matrix_client
  ; create_chat = Create_chat.init matrix_client
  }


let update model = function
  | ChatMsg chat_msg ->
      let chat, chat_cmd = Chat.update model.chat chat_msg in
      ({ model with chat }, Tea.Cmd.map chatMsg chat_cmd)
  | GroupMsg (GoTo route) ->
      (model, Tea.Cmd.msg (GoTo route))
  | GroupMsg group_msg ->
      let group, group_cmd = Group.update model.group group_msg in
      ({ model with group }, Tea.Cmd.map groupMsg group_cmd)
  | CreateGroupMsg create_group_msg ->
      let create_group, create_group_cmd =
        Create_group.update model.create_group create_group_msg
      in
      ({ model with create_group }, Tea.Cmd.map createGroupMsg create_group_cmd)
  | LoginMsg (GoTo route) ->
      (model, Tea.Cmd.msg (GoTo route))
  | LoginMsg login_msg ->
      let login, login_cmd = Login.update model.login login_msg in
      ({ model with login }, Tea.Cmd.map loginMsg login_cmd)
  | GoTo _ ->
      (* this should never match *)
      (model, Tea.Cmd.none)
  | SignupMsg (GoTo route) ->
      (model, Tea.Cmd.msg (GoTo route))
  | SignupMsg signup_msg ->
      let signup, signup_cmd = Signup.update model.signup signup_msg in
      ({ model with signup }, Tea.Cmd.map signupMsg signup_cmd)
  | CreateChatMsg (GoTo route) ->
      (model, Tea.Cmd.msg (GoTo route))
  | CreateChatMsg create_chat_msg ->
      let create_chat, create_chat_cmd =
        Create_chat.update model.create_chat create_chat_msg
      in
      ({ model with create_chat }, Tea.Cmd.map createChatMsg create_chat_cmd)


let logged_out_index_view _model =
  let open Tea.Html in
  div
    [ id "logged-out-index" ]
    [ h3 [ id "welcome" ] [ text "Bienvenue sur Imago !" ]
    ]


let logged_in_index_view _model =
  let open Tea.Html in
  div [] []


let index_view model =
  if Auth.is_logged_in model.matrix_client
  then logged_in_index_view model
  else logged_out_index_view model


let view (route : Router.route) model =
  let open Tea.Html in
  div
    [ id "content" ]
    [ ( match route with
      | Index ->
          index_view model
      | Login ->
          Login.view model.login |> Vdom.map loginMsg
      | Signup ->
          Signup.view model.signup |> Vdom.map signupMsg
      | Logout ->
          div [] []
      | CreateGroup ->
          Create_group.view model.create_group |> Vdom.map createGroupMsg
      | Chat (Id room_id) ->
          Chat.view model.chat room_id |> Vdom.map chatMsg
      | Chat (Alias _room_alias) ->
          index_view model (* XXX *)
      | Group _room_address ->
          Group.view model.group |> Vdom.map groupMsg
      | CreateChat maybe_group ->
          Create_chat.view model.create_chat maybe_group
          |> Vdom.map createChatMsg )
    ]
