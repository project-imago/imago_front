open Tea.Html
open Router

(* let matrix_client = ref (Matrix.create_client "https://matrix.imago.local:8448") *)

type msg =
  | AuthMsg of Auth.msg
  | ContentMsg of Content.msg
  | HeaderMsg of Header.msg
  | SidebarMsg of Sidebar.msg
  | Location_changed of Web.Location.location
  | GoTo of route (* | Logout *)
[@@bs.deriving { accessors }]

let msg_to_string (msg : msg) =
  match msg with
  | AuthMsg authMsg ->
      "auth msg: " ^ Auth.msg_to_string authMsg
  | ContentMsg contentMsg ->
      Content.msg_to_string contentMsg
  | HeaderMsg _headerMsg ->
      "header msg"
  | SidebarMsg _sidebarMsg ->
      "sidebar msg"
  | Location_changed _ ->
      "location changed"
  | GoTo _ ->
      "go to"


(* | Logout -> "logout" *)

type model =
  { matrix_client : Matrix.client ref
  ; auth : Auth.model
  ; content : Content.model
  ; sidebar : Sidebar.model
  ; header : Header.model
  ; route : Router.route
  }

let update_route model = function
  | route when model.route = route ->
      (model, Tea.Cmd.none)
  (* | AuthRoute auth_route -> *)
  (*     let auth, route = Auth.update_route model.auth auth_route in *)
  (*     {auth; route}, location_of_route route |> Tea.Navigation.newUrl *)
  | Chat room_address as route ->
      Js.log "updating route group" ;
      Router.set_title_for_route route ;
      let chat_cmd = Chat.set_chat_room model.content.chat room_address in
      ( { model with route }
      , Tea.Cmd.batch
          [ Tea.Cmd.map (fun m -> contentMsg (Content.chatMsg m)) chat_cmd
          ; location_of_route route |> Tea.Navigation.newUrl
          ] )
  | Group room_address as route ->
      Js.log "updating route group" ;
      Router.set_title_for_route route ;
      let group_cmd = Group.set_group_room model.content.group room_address in
      ( { model with route }
      , Tea.Cmd.batch
          [ Tea.Cmd.map (fun m -> contentMsg (Content.groupMsg m)) group_cmd
          ; location_of_route route |> Tea.Navigation.newUrl
          ] )
  | Logout ->
      let auth_cmd = Auth.logout model.auth.matrix_client in
      ( model
      , Tea.Cmd.batch [ Tea.Cmd.map authMsg auth_cmd; Tea.Cmd.msg (GoTo Index) ]
      )
  | route ->
      Router.set_title_for_route route ;
      ({ model with route }, location_of_route route |> Tea.Navigation.newUrl)


let init () location =
  let matrix_client = ref (Matrix.create_client ()) in
  let auth_model, auth_cmd = Auth.init matrix_client in
  let model =
    { matrix_client
    ; auth = auth_model
    ; content = Content.init matrix_client
    ; sidebar = Sidebar.init matrix_client
    ; header = Header.init matrix_client
    ; route = Index
    }
  in
  Js.log (route_of_location location) ;
  let model, location_cmd = route_of_location location |> update_route model in
  (* let auth_cmd = Auth.init_cmd in *)
  let cmd = Tea.Cmd.batch [ Tea.Cmd.map authMsg auth_cmd; location_cmd ] in
  (model, cmd)


let update model = function
  (* | Logout -> *)
  (*     {model with auth = Auth.logout model.auth}, Tea.Cmd.none *)
  | Location_changed location ->
      ({ model with route = route_of_location location }, Tea.Cmd.none)
      (* route_of_location location |> update_route model *)
  | GoTo route ->
      update_route model route
  | AuthMsg (GoTo route) ->
      update_route model route
  | SidebarMsg (GoTo route) ->
      update_route model route
  | HeaderMsg (GoTo route) ->
      update_route model route
  | HeaderMsg ToggleMenu ->
      let model =
        { model with
          sidebar =
            { model.sidebar with show_menu = not model.sidebar.show_menu }
        }
      in
      (model, Tea.Cmd.none)
  | HeaderMsg header_msg ->
      let header, header_cmd = Header.update model.header header_msg in
      ({ model with header }, Tea.Cmd.map headerMsg header_cmd)
  | ContentMsg (GoTo route) ->
      update_route model route
  | ContentMsg content_msg ->
      let content, content_cmd = Content.update model.content content_msg in
      ({ model with content }, Tea.Cmd.map contentMsg content_cmd)
  | AuthMsg auth_msg ->
      let auth, auth_cmd = Auth.update model.auth auth_msg in
      ({ model with auth }, Tea.Cmd.map authMsg auth_cmd)


let view model =
  div
    [ id "body"
    ; classList
        [ ("dark", model.header.current_color_theme == Dark)
        ; ("light", model.header.current_color_theme == Light)
        ]
    ]
    [ Header.view model.header |> Vdom.map headerMsg
    ; main
        []
        [ Sidebar.view model.route model.sidebar |> Vdom.map sidebarMsg
        ; Content.view model.route model.content |> Vdom.map contentMsg
        ]
    ; footer ~key:"footer" [] [ text "Imago 2020" ]
    ]


let subscriptions model =
  (* Tea.Sub.none *)
  Tea.Sub.batch
    [ Auth.subscriptions model.auth |> Tea.Sub.map authMsg
    ; Chat.subscriptions model.content.chat
      |> Tea.Sub.map (fun m -> contentMsg (Content.chatMsg m))
    ]


let start_app container =
  let _ =
    Tea.Navigation.navigationProgram
      location_changed
      { init; update; view; subscriptions; shutdown = (fun _ -> Tea.Cmd.none) }
      container
      ()
  in
  ()


let start_dev_app container cachedModel =
  (* Replace the existing shutdown function with one that returns the current
   * state of the app, for hot module replacement purposes *)
  (* copied from https://github.com/walfie/ac-tune-maker *)
  let modelRef = ref None in
  let shutdown model =
    let () = modelRef := Some model in
    Tea.Cmd.none
  in
  let init =
    match cachedModel with
    | None ->
        init
    | Some model ->
        fun _flags _location -> (model, Tea.Cmd.none)
  in
  let app =
    Tea.Debug.navigationProgram
      location_changed
      { init; update; view; subscriptions; shutdown }
      msg_to_string
      container
      ()
  in
  let oldShutdown = app##shutdown in
  let newShutdown () =
    let () = oldShutdown () in
    !modelRef
  in
  let _ = Js.Obj.assign app [%obj { shutdown = newShutdown }] in
  newShutdown
