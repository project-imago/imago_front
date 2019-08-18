type route =
  | Index
  | Room of Matrix.room_id

let route_of_location location =
  let route = Js.String.split "/" location.Web.Location.hash in
  match route with
  | [|"#"; "room"; id|] -> Room id
  | _ -> Index  (* default route *)

let location_of_route = function
  | Room id -> Printf.sprintf "#/room/%s" id
  | Index -> "#/"

