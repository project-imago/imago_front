type client
type login_map
type login_response = <user_id:string; access_token:string; home_server:string;
device_id: string> Js.t

external create_client: string -> client = "createClient" [@@bs.module "matrix-js-sdk"]

external login: client -> string -> string Js.Dict.t -> login_response Js.Promise.t = "login" [@@bs.send]

external on: client -> string -> (string -> unit) = "on" [@@bs.send]

external start_client: client -> unit = "startClient" [@@bs.send]

let new_client () =
  create_client "https://imago-dev.img:8448"

let login client =
  let login_map = Js.Dict.empty () in
  let () = Js.Dict.set login_map "user" "alice" in
  let () = Js.Dict.set login_map "password" "imago42imago" in
  login client "m.login.password" login_map

let add a b = a + b
