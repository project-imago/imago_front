type model =
  {
    matrix_client : Matrix.client ref;
  }

type msg =
  | GoTo of Router.route
  [@@bs.deriving {accessors}]

let msg_to_string _msg = "content msg"

let init matrix_client = 
  {
    matrix_client;
  }

let equal_to_option value = function
  | None -> false
  | Some v -> v = value

let equal_to_room room (route : Router.route) =
  match route with
  | Room room_id -> room_id = room##roomId
  | _ -> false

let room_list_view route model =
  let open Tea.Html in
  let rooms = Js.Dict.values !(model.matrix_client)##store##rooms in
    ul
      []
      (rooms
      |. Belt.Array.map (fun room ->
          let room_name_text =
            if equal_to_room room route then
              text ("* " ^ room##name)
            else
              text room##name in
        li [] [button [ onClick (GoTo (Room room##roomId))]
        [room_name_text]])
      |> Belt.List.fromArray)

let view route model =
  let open Tea.Html in
  div [ id "sidebar" ] [
    button [ onClick (GoTo CreateGroup)] [text "Create group"];
    room_list_view route model;
    button [ onClick (GoTo Index)] [text "Index"]
  ];

