type model =
  {
    room : Room.model;
  }

type msg =
  | RoomMsg of Room.msg
  [@@bs.deriving {accessors}]

let msg_to_string _msg = "content msg"

let init matrix_client = 
  {
    room = Room.init matrix_client;
  }

let view (route : Router.route) model =
  let open Tea.Html in
  div [ id "content" ]
  [
    match route with
    | Index -> div [] [text "Welcome"]
    | Login -> div [] []
    | Logout -> div [] []
    | CreateGroup -> div [] []
    | Room room_id -> Room.view model.room room_id |> Vdom.map roomMsg
  ]

