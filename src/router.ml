type chat_route =
  | Room of Matrix.room_id

type route =
  | Index
  | ChatRoute of chat_route

let route_of_location location =
  let route = Js.String.split "/" location.Web.Location.hash in
  match route with
  | [|"#"; "room"; room_id|] -> ChatRoute (Room room_id)
  | _ -> Index  (* default route *)

let location_of_route = function
  | ChatRoute (Room room_id) -> Printf.sprintf "#/room/%s" room_id
  | Index -> "#/"

