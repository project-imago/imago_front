type route =
  | Index
  | Login
  | Signup
  | Logout
  | CreateGroup
  | Room of Matrix.room_id

let route_of_location location =
  let route = Js.String.split "/" location.Web.Location.pathname in
  (* let () = Js.log route in *)
  match route with
  | [|""; "login"|] -> Login
  | [|""; "signup"|] -> Signup
  | [|""; "logout"|] -> Logout
  | [|""; "group"; "new"|] -> CreateGroup
  | [|""; "room"; room_id|] -> Room room_id
  | _ -> Index  (* default route *)

let location_of_route = function
  | Index -> "/"
  | Login -> "/login"
  | Signup -> "/signup"
  | Logout -> "/logout"
  | CreateGroup -> "/group/new"
  | Room room_id -> Printf.sprintf "/room/%s" room_id

