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
  | Chat room_id -> room_id = room##roomId
  | _ -> false

module RoomCmp =
  Belt.Id.MakeComparable
  (struct
    type t = Matrix.room option
    let cmp ao bo = match (ao, bo) with
    | (Some a, Some b) ->
      String.compare a##roomId b##roomId
    | (Some _, None) -> -1
    | (None, Some _) -> 1
    | (None, None) -> 0
  end)

type room_tree = (RoomCmp.t, (Matrix.room list), RoomCmp.identity) Belt.Map.t

type room_type =
  | Group
  | SubChat of Matrix.room
  | Chat

let get_room_type room matrix_client =
  let room_type =
    let room_state = room##currentState in
    let state_type = Matrix.get_state_type room_state in
    match state_type with
    | [|state_event|] ->
        (match (state_event##getContent ())##_type with
        | "group" -> Group
        | _ -> Chat)
    | _ ->
        Chat
  in
  let room_group =
    let room_state = room##currentState in
    let state_type = Matrix.get_state_group room_state in
    match state_type with
    | [|state_event|] ->
        Some ((state_event##getContent ())##id)
    | _ ->
        None
  in
  match (room_type, room_group) with
  | (Group, _) -> Group
  | (_, Some group) -> SubChat (matrix_client##getRoom group)
  | (_, None) -> Chat


let room_list_view route model =
  let open Tea.Html in
  (* let () = Js.log !(model.matrix_client) in *)
  (* TODO: fix trouver si connecté (et username si oui) *)
  let rooms = Js.Dict.values !(model.matrix_client)##store##rooms in
  let rooms_t_empty = Belt.Map.make ~id:(module RoomCmp) in
  let rooms_t : room_tree =
    Belt.Array.reduce rooms rooms_t_empty (fun acc room ->
      match get_room_type room !(model.matrix_client) with
      | Group ->
          Belt.Map.set acc (Some room) []
      | SubChat group ->
          Belt.Map.update acc (Some group)
          (function
            | None -> Some (Belt.List.make 1 room)
            | Some chats -> Some (Belt.List.concat chats [room])
          )
      | Chat ->
          Belt.Map.update acc (None)
          (function
            | None -> Some (Belt.List.make 1 room)
            | Some chats -> Some (Belt.List.concat chats [room])
          )
  ) in
  let room_view room =
    (* let () = Js.log room in *)
    (* let () = Js.log !(model.matrix_client) in *)
    li [] [
      Router.link goTo (Chat room##roomId)
      (div
      [classList
        [("chat_link", true);
         ("active", equal_to_room room route)]]
      [text room##name])
      ]
  in
  let group_view (group, chats) =
    match group with
    | Some g ->
        li [] [
          div
          [classList
            [("group_link", true);
             ("active", equal_to_room g route)]]
          [ Router.link goTo (Chat g##roomId)
              (span [] [text g##name]);
            Router.link goTo (CreateChat (Some g##roomId))
              (span [class' "create_chat_link"] [text "+"])
          ];
          ul []
          (Belt.List.map chats room_view)
        ]
    | None ->
        li [] [
          div [class' "group_link"] [
            span [] [text "Outside groups"];
            Router.link goTo (CreateChat None)
            (span [class' "create_chat_link"] [text "+"])
          ];
          ul []
          (Belt.List.map chats room_view)
        ]
  in
  ul
    []
    (* (rooms *)
    (* |. Belt.Array.map room_view *)
    (* |> Belt.List.fromArray) *)
    (Belt.Map.toList rooms_t
    |. Belt.List.map group_view
    )

let view route model =
  let open Tea.Html in
  div [ id "sidebar" ] [
    Router.link goTo Router.CreateGroup (div [class' "button"] [text "Create Group"]);
    room_list_view route model;
  ];

