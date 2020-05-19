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
  ; route : Router.route
  }

let update_route model = function
  | route when model.route = route ->
      (model, Tea.Cmd.none)
  (* | AuthRoute auth_route -> *)
  (*     let auth, route = Auth.update_route model.auth auth_route in *)
  (*     {auth; route}, location_of_route route |> Tea.Navigation.newUrl *)
  | Logout as route ->
      let () = Auth.logout model.auth.matrix_client in
      ( { model with route }
      , Tea.Cmd.batch
          [ Tea.Cmd.map authMsg Auth.remove_storage_cmd
          ; location_of_route Index |> Tea.Navigation.newUrl
          ] )
  | route ->
      ({ model with route }, location_of_route route |> Tea.Navigation.newUrl)


let init () location =
  let matrix_client = ref (Auth.create_client ()) in
  let auth_model, auth_cmd = Auth.init matrix_client in
  let model =
    { matrix_client
    ; auth = auth_model
    ; content = Content.init matrix_client
    ; sidebar = Sidebar.init matrix_client
    ; route = Index
    }
  in
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
  | HeaderMsg (GoTo route) ->
      update_route model route
  | SidebarMsg (GoTo route) ->
      update_route model route
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
    [ id "body" ]
    [ Header.view model.matrix_client |> Vdom.map headerMsg
    ; main
        []
        [ Sidebar.view model.route model.sidebar |> Vdom.map sidebarMsg
        ; Content.view model.route model.content |> Vdom.map contentMsg
        ]
    ; footer [] [ text "Imago 2020" ]
    ]


let subscriptions model =
  (* Tea.Sub.none *)
  Auth.subscriptions model.auth |> Tea.Sub.map authMsg


let main =
  Tea.Debug.navigationProgram
    location_changed
    { init; update; view; subscriptions; shutdown = (fun _ -> Tea.Cmd.none) }
    msg_to_string
