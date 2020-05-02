open Tea.Html
open Router

let matrix_client = ref (Matrix.create_client "https://matrix.imago.local:8448")

type msg =
  | ChatMsg of Chat.msg
  | ContentMsg of Content.msg
  | HeaderMsg of Header.msg
  | SidebarMsg of Sidebar.msg
  | Location_changed of Web.Location.location
  | GoTo of route
  (* | Logout *)
  [@@bs.deriving {accessors}]

let msg_to_string (msg : msg) =
  match msg with
  | ChatMsg chatMsg -> "chat msg: " ^ Chat.msg_to_string chatMsg
  | ContentMsg contentMsg -> Content.msg_to_string contentMsg
  | HeaderMsg _headerMsg -> "header msg"
  | SidebarMsg _sidebarMsg -> "sidebar msg"
  | Location_changed _ -> "location changed"
  | GoTo _ -> "go to"
  (* | Logout -> "logout" *)

type model =
  {
    chat : Chat.model;
    content: Content.model;
    sidebar : Sidebar.model;
    route : Router.route;
  }

let update_route model = function
  | route when model.route = route -> (model, Tea.Cmd.none)
  (* | ChatRoute chat_route -> *)
  (*     let chat, route = Chat.update_route model.chat chat_route in *)
  (*     {chat; route}, location_of_route route |> Tea.Navigation.newUrl *)
  | Logout as route ->
      let () = Auth.logout model.chat.matrix_client in
      {model with route = route},
      location_of_route Index |> Tea.Navigation.newUrl
  | route ->
      {model with route = route},
      location_of_route route |> Tea.Navigation.newUrl

let init () location =
  let chat_model, chat_cmd = Chat.init matrix_client in
  let model =
    {
      chat = chat_model;
      content = Content.init matrix_client;
      sidebar = Sidebar.init matrix_client;
      route = Index;
    } in
  let model, location_cmd =
    route_of_location location |> update_route model in
  (* let chat_cmd = Chat.init_cmd in *)
  let cmd =
    Tea.Cmd.batch [
      Tea.Cmd.map chatMsg chat_cmd;
      location_cmd
    ]
  in
  (model, cmd)

let update model = function
  (* | Logout -> *)
  (*     {model with chat = Auth.logout model.chat}, Tea.Cmd.none *)
  | Location_changed location ->
      {model with route = route_of_location location;},
      Tea.Cmd.none
      (* route_of_location location |> update_route model *)
  | GoTo route -> update_route model route
  | ChatMsg (GoTo route) -> update_route model route
  | HeaderMsg (GoTo route) -> update_route model route
  | SidebarMsg (GoTo route) -> update_route model route
  | ContentMsg (GoTo route) -> update_route model route
  | ContentMsg content_msg ->
      let content, content_cmd = Content.update model.content content_msg in
      {model with content},
      Tea.Cmd.map contentMsg content_cmd
  | ChatMsg chat_msg ->
      let chat, chat_cmd = Chat.update model.chat chat_msg in
      {model with chat},
      Tea.Cmd.map chatMsg chat_cmd

let view model =
  div
    [ id "body" ]
    [
      Header.view !matrix_client##clientRunning
      !matrix_client##credentials##userId |> Vdom.map headerMsg;
      main []
      [
        Sidebar.view model.route model.sidebar |> Vdom.map sidebarMsg;
        Content.view model.route model.content |> Vdom.map contentMsg;

      ];
      footer [] [ text "Imago 2020" ]
    ]

let subscriptions model =
  (* Tea.Sub.none *)
  Chat.subscriptions model.chat |> Tea.Sub.map chatMsg

let main =
  Tea.Debug.navigationProgram location_changed {
    init;
    update;
    view;
    subscriptions = subscriptions;
    shutdown = (fun _ -> Tea.Cmd.none);
  } msg_to_string
