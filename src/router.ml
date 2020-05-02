type route =
  | Index
  | Login
  | Signup
  | Logout
  | CreateGroup
  | CreateChat of Matrix.room_id option
  | Room of Matrix.room_id

let route_of_location location =
  let parse_params params =
    params
    |> Js.String.sliceToEnd ~from:1
    |> Js.String.split "&"
    |. Belt.Array.reduce Belt.Map.String.empty  (fun acc param ->
        match Js.String.split param "=" with
        | [|key; value|] ->
          Belt.Map.String.set acc key value
        | _ -> acc
        )
  in
  let route = Js.String.split "/" location.Web.Location.pathname in
  let () = Js.log (Js.String.split "/" location.Web.Location.pathname) in
  match route with
  | [|""; "login"|] -> Login
  | [|""; "signup"|] -> Signup
  | [|""; "logout"|] -> Logout
  | [|""; "group"; "new"|] -> CreateGroup
  | [|""; "room"; "new"|] ->
      let group =
        parse_params location.Web.Location.search
        |. Belt.Map.String.get "group" in
      CreateChat group
  | [|""; "room"; room_id|] -> Room room_id
  | _ -> Index  (* default route *)

let location_of_route = function
  | Index -> "/"
  | Login -> "/login"
  | Signup -> "/signup"
  | Logout -> "/logout"
  | CreateGroup -> "/group/new"
  | CreateChat None -> "/room/new"
  | CreateChat (Some group_id) -> "/room/new?group=" ^ group_id
  | Room room_id -> Printf.sprintf "/room/%s" room_id

let link msg route content =
  let open Tea.Html in
  a [href (location_of_route route);
    Tea.Html2.Events.preventDefaultOn
      "click"
      (Tea_json.Decoder.succeed (msg route))]
    [content]
