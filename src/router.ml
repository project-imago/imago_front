type route =
  | Index
  | Login
  | Signup
  | Logout
  | CreateGroup
  | CreateChat of Matrix.room_id option
  | Chat of Matrix.room_address
  | Group of Matrix.room_address

module StringCmp = Belt.Id.MakeComparable (struct
  type t = string

  let cmp a b = String.compare a b
end)

type route_params = (StringCmp.t, string, StringCmp.identity) Belt.Map.t

(* we use Belt.Map until Belt.Map.String is fixed *)

let route_of_location location =
  (* let as_list = Belt.Array.toList input in *)
  let rec list_to_map output = function
    | key :: value :: rest ->
        list_to_map (Belt.Map.set output key value) rest
    | _ ->
        output
  in
  let parse_params params =
    params
    |> Js.String.sliceToEnd ~from:1
    |> Js.String.split "&"
    |> Array.to_list
    |. Belt.List.map (fun kv -> Js.String.split "=" kv |> Array.to_list)
    |> Belt.List.flatten
    |> list_to_map (Belt.Map.make ~id:(module StringCmp))
  in
  (* Js.log location; *)
  (* Js.log (parse_params location.Web.Location.search); *)
  let route = Js.String.split "/" (location.Web.Location.pathname ^
  location.Web.Location.hash) in
  (* let () = Js.log (Js.String.split "/" location.Web.Location.pathname) in *)
  match route with
  | [| ""; "login" |] ->
      Login
  | [| ""; "signup" |] ->
      Signup
  | [| ""; "logout" |] ->
      Logout
  | [| ""; "chat"; "new" |] ->
      let group =
        parse_params location.Web.Location.search |. Belt.Map.get "group"
      in
      CreateChat group
  | [| ""; "chat"; room_address |] ->
      (match Js.String.charAt 0 (Js.Global.decodeURIComponent room_address) with
      | "!" -> Chat (Id room_address)
      | "#" -> Chat (Alias room_address)
      | _ -> Index)
  | [| ""; "group"; "new" |] ->
      CreateGroup
  | [| ""; "group"; room_address |] ->
      (* match Js.String.charAt 0 room_id with *)
      (* "#" -> *)
      (* "!" -> *)
      (match Js.String.charAt 0 (Js.Global.decodeURIComponent room_address) with
      | "!" -> Group (Id room_address)
      | "#" -> Group (Alias room_address)
      | _ -> Index)
  | _ ->
      Index


(* default route *)

let location_of_route = function
  | Index ->
      "/"
  | Login ->
      "/login"
  | Signup ->
      "/signup"
  | Logout ->
      "/logout"
  | CreateGroup ->
      "/group/new"
  | CreateChat None ->
      "/chat/new"
  | CreateChat (Some group_id) ->
      "/chat/new?group=" ^ group_id
  | Chat (Id room_id) ->
      Printf.sprintf "/chat/%s" room_id
  | Chat (Alias room_alias) ->
      Printf.sprintf "/chat/%s" room_alias
  | Group (Id room_id) ->
      Printf.sprintf "/group/%s" room_id
  | Group (Alias room_alias) ->
      Printf.sprintf "/group/%s" room_alias


let link ?(key="") ?(unique="") ?(props = []) msg route content =
  let open Tea.Html in
  a ~key ~unique
    ( props
    @ [ href (location_of_route route)
      ; Tea.Html2.Events.preventDefaultOn
          "click"
          (Tea_json.Decoder.succeed (msg route))
      ] )
    content
