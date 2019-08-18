[%%debugger.chrome]
open Tea.App
open Tea.Html

type route =
  | Index
  | Room of Matrix.room_id

type msg =
  | ChatMsg of Chat.msg
  | Location_changed of Web.Location.location
  | GoTo of route
  [@@bs.deriving {accessors}]

type model =
  {
    chat : Chat.model;
    route : route;
  }

let route_of_location location =
  let route = Js.String.split "/" location.Web.Location.hash in
  match route with
  | [|"#"; "room"; id|] -> Room id
  | _ -> Index  (* default route *)

let location_of_route = function
  | Room id -> Printf.sprintf "#/room/%s" id
  | Index -> "#/"

let update_route model = function
  | route when model.route = route -> (model, Tea.Cmd.none)
  | Room _ as route ->
      {model with route}, location_of_route route |> Tea.Navigation.newUrl
  | Index as route ->
      {model with route}, location_of_route route |> Tea.Navigation.newUrl

let init () location =
  Js.log "init";
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
  | Location_changed location ->
      route_of_location location |> update_route model
  | GoTo route -> update_route model route
  | ChatMsg chat_msg ->
      let chat, chat_cmd = Chat.update model.chat chat_msg in
      {model with chat}, Tea.Cmd.map chatMsg chat_cmd

let content model =
  Js.log model;
  match model.route with
  | Index ->
      ul
        []
        (Belt.List.map model.chat.joined_rooms_ids (fun room_id ->
          li [] [button [ onClick (GoTo (Room room_id))] [text room_id]]))
  | Room id -> div [] []

let view model =
  div
    []
    [ span
        [ style "text-weight" "bold" ]
        [ text (match model.chat.matrix_id with Some str -> str | None ->
          "disconnected") ];
      content model;
      button [ onClick (GoTo Index)] [text "Index"]
    ]

let main =
  Tea.Navigation.navigationProgram location_changed {
    init;
    update;
    view;
    subscriptions = (fun _ -> Tea.Sub.none);
    shutdown = (fun _ -> Tea.Cmd.none);
  }
