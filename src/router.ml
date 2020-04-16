type route =
  | Index
  | Login
  | Logout
  | CreateGroup
  | Room of Matrix.room_id

let route_of_location location =
  let route = Js.String.split "/" location.Web.Location.hash in
  match route with
  | [|"#"; "login"|] -> Login
  | [|"#"; "logout"|] -> Logout
  | [|"#"; "group"; "new"|] -> CreateGroup
  | [|"#"; "room"; room_id|] -> Room room_id
  | _ -> Index  (* default route *)

let location_of_route = function
  | Index -> "#/"
  | Login -> "#/login"
  | Logout -> "#/logout"
  | CreateGroup -> "#/group/new"
  | Room room_id -> Printf.sprintf "#/room/%s" room_id

