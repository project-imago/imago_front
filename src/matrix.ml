type user_id = string
type client =
  < credentials: < user_id : user_id > Js.t
  > Js.t
type room_id = string
type access_token = string
type home_server = string
type device_id = string
type login_map = string Js.Dict.t
type login_response = <user_id:user_id; access_token:access_token;
home_server:home_server; device_id: device_id> Js.t

external create_client: string -> client = "createClient" [@@bs.module "matrix-js-sdk"]
external create_client_params: string Js.Dict.t -> client = "createClient" [@@bs.module "matrix-js-sdk"]

external login: client -> string -> string Js.Dict.t -> login_response Js.Promise.t = "login" [@@bs.send]

external on: client -> string -> (string -> unit) = "on" [@@bs.send]

external get_joined_rooms_: client -> (<joined_rooms: room_id array> Js.t) Js.Promise.t = "getJoinedRooms" [@@bs.send]

let get_joined_rooms client =
  get_joined_rooms_ client
  |> Js.Promise.then_ (fun res ->
      res##joined_rooms
      |> Tablecloth.Array.to_list
      |> Js.Promise.resolve
  )

external start_client: client -> unit = "startClient" [@@bs.send]

let new_client () =
  create_client "https://imago-dev.img:8448"

let new_client_params matrix_id access_token =
  let login_map = Js.Dict.empty () in
  let () = Js.Dict.set login_map "baseUrl"  "https://imago-dev.img:8448" in
  let () = Js.Dict.set login_map "accessToken" access_token in
  let () = Js.Dict.set login_map "userId" matrix_id in
  create_client_params login_map

let login client =
  let login_map = Js.Dict.empty () in
  let () = Js.Dict.set login_map "user" "alice" in
  let () = Js.Dict.set login_map "password" "imago42imago" in
  login client "m.login.password" login_map
