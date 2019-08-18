[%%debugger.chrome]
open Tea.App
open Tea.Html

type route =
  | Index
  | Room of Matrix.room_id

type msg =
  | Login of (Matrix.login_response, string) Tea.Result.t
  | GetJoinedRooms of (Matrix.room_id list, string) Tea.Result.t
  | Location_changed of Web.Location.location
  | GoTo of route
  [@@bs.deriving {accessors}]

type model =
  {
    client : Matrix.client;
    matrix_id : string option;
    joined_rooms_ids : Matrix.room_id list;
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
  let client = Matrix.new_client () in
  let model =
    { client
    ; matrix_id = None
    ; joined_rooms_ids = []
    ; route = Index
    } in
  let login_cmd = Tea_promise.result (Matrix.login client) login in
  let model, location_cmd =
    route_of_location location |> update_route model
  in
  (model, Tea.Cmd.batch [login_cmd; location_cmd])

let update model = function
  | GetJoinedRooms (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let model = {model with joined_rooms_ids = res} in
      model, Tea.Cmd.none
  | GetJoinedRooms (Tea.Result.Error err) -> 
      let () = Js.log err in
      model, Tea.Cmd.none
  | Login (Tea.Result.Ok res) -> 
      let () = Js.log res in
      let model = {model with matrix_id = Some res##user_id} in
      let cmd = Tea_promise.result (Matrix.get_joined_rooms model.client)
      getJoinedRooms in
      model, cmd
  | Login (Tea.Result.Error err) -> 
      let () = Js.log err in
      model, Tea.Cmd.none
  | Location_changed location ->
      route_of_location location |> update_route model
  | GoTo route -> update_route model route

let content model =
  Js.log model;
  match model.route with
  | Index ->
      ul
        []
        (Belt.List.map model.joined_rooms_ids (fun room_id ->
          li [] [button [ onClick (GoTo (Room room_id))] [text room_id]]))
  | Room id -> div [] []

let view model =
  div
    []
    [ span
        [ style "text-weight" "bold" ]
        [ text (match model.matrix_id with Some str -> str | None ->
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
