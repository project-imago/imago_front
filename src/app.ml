open Tea.Html
open Router

type msg =
  | ChatMsg of Chat.msg
  | Location_changed of Web.Location.location
  | GoTo of route
  | Logout
  [@@bs.deriving {accessors}]

let msg_to_string (msg : msg) =
  match msg with
  | ChatMsg chatMsg -> "chat msg: " ^ Chat.msg_to_string chatMsg
  | Location_changed _ -> "location changed"
  | GoTo _ -> "go to"
  | Logout -> "logout"

type model =
  {
    chat : Chat.model;
    route : Router.route;
  }

let update_route model = function
  | route when model.route = route -> (model, Tea.Cmd.none)
  | ChatRoute chat_route ->
      let chat, route = Chat.update_route model.chat chat_route in
      {chat; route}, location_of_route route |> Tea.Navigation.newUrl
  | Index as route ->
      let chat = Chat.reset_route model.chat in
      {chat; route}, location_of_route route |> Tea.Navigation.newUrl

let init () location =
  let chat_model, chat_cmd = Chat.init in
  let model =
    {
      chat = chat_model;
      route = Index;
    } in
  let model, location_cmd =
    route_of_location location |> update_route model
  in
  (model, Tea.Cmd.batch [Tea.Cmd.map chatMsg chat_cmd; location_cmd])

let update model = function
  | Logout ->
      {model with chat = Auth.logout model.chat}, Tea.Cmd.none
  | Location_changed location ->
      route_of_location location |> update_route model
  | GoTo route -> update_route model route
  | ChatMsg (GoTo route) -> update_route model route
  | ChatMsg chat_msg ->
      let chat, chat_cmd = Chat.update model.chat chat_msg in
      {model with chat}, Tea.Cmd.map chatMsg chat_cmd

let content model =
  match model.route with
  | Index -> div [] []
  | ChatRoute chat_route -> Chat.view model.chat chat_route |> Vdom.map chatMsg

let view model =
  div
    [ id "body" ]
    [ header [ style "text-weight" "bold" ]
        (if model.chat.client##clientRunning then
          let () = Js.log model.chat.client in
          [ p [] [(text model.chat.client##credentials##userId)];
            button [ onClick (Logout)] [text "Logout"]
          ]
         else
           [ p [] [(text "disconnected")];
            button [ onClick (GoTo Index)] [text "Index"]
           ]);
      main [] [
        div [ id "sidebar" ] [
          Chat.room_list_view model.chat |> Vdom.map chatMsg;
          button [ onClick (GoTo Index)] [text "Index"]
        ];
        div [ id "content" ] [ content model ]
      ];
      footer [] [ text "Imago 2020" ]
    ]

let subscriptions model =
  Chat.subscriptions model.chat |> Tea.Sub.map chatMsg

let main =
  Tea.Debug.navigationProgram location_changed {
    init;
    update;
    view;
    subscriptions = subscriptions;
    shutdown = (fun _ -> Tea.Cmd.none);
  } msg_to_string
