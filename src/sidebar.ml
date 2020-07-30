type model = { matrix_client : Matrix.client ref; show_menu : bool }

type msg = GoTo of Router.route [@@bs.deriving { accessors }]

let msg_to_string _msg = "content msg"

let init matrix_client = { show_menu = true; matrix_client }

let equal_to_option value = function None -> false | Some v -> v = value

let room_aliases room =
  match room##getCanonicalAlias () |> Js.Nullable.toOption with
  | None ->
      room##getAltAliases ()
  | Some alias ->
      Tablecloth.Array.append (room##getAltAliases ()) [| alias |]


let equal_to_room room (route : Router.route) =
  match route with
  | Chat (Id room_id) ->
      room_id = room##roomId
  | Chat (Alias room_alias) ->
      Tablecloth.Array.any (room_aliases room) ~f:(fun a -> a = room_alias)
  | Group (Id room_id) ->
      room_id = room##roomId
  | Group (Alias room_alias) ->
      Tablecloth.Array.any (room_aliases room) ~f:(fun a -> a = room_alias)
  | _ ->
      false


module RoomCmp = Belt.Id.MakeComparable (struct
  type t = Matrix.room option

  let cmp ao bo =
    match (ao, bo) with
    | Some a, Some b ->
        String.compare a##roomId b##roomId
    | Some _, None ->
        -1
    | None, Some _ ->
        1
    | None, None ->
        0
end)

type room_tree = (RoomCmp.t, Matrix.room list, RoomCmp.identity) Belt.Map.t

type room_type =
  | Group
  | SubChat of Matrix.room
  | Chat

let get_room_type room matrix_client =
  let room_type =
    let room_state = room##currentState in
    let state_type = Matrix.TypeState.get room_state "pm.imago.type" in
    match state_type with
    | [| state_event |] ->
      ( match (state_event##getContent ())##_type with
      | "group" ->
          Group
      | _ ->
          Chat )
    | _ ->
        Chat
  in
  let room_group =
    let room_state = room##currentState in
    let state_type = Matrix.IdState.get room_state "pm.imago.group" in
    match state_type with
    | [| state_event |] ->
        Some (state_event##getContent ())##id
    | _ ->
        None
  in
  match (room_type, room_group) with
  | Group, _ ->
      Group
  | _, Some group ->
      (match matrix_client##getRoom group |> Js.Nullable.toOption with
      | Some g -> SubChat g
      | None -> Chat)
  | _, None ->
      Chat


let room_list_view route model =
  let open Tea.Html in
  (* let () = Js.log !(model.matrix_client) in *)
  (* TODO: fix trouver si connecté (et username si oui) *)
  let rooms = Js.Dict.values !(model.matrix_client)##store##rooms in
  let rooms_t_empty =
    Belt.Map.make ~id:(module RoomCmp) |. Belt.Map.set None []
  in
  let rooms_t : room_tree =
    Belt.Array.reduce rooms rooms_t_empty (fun acc room ->
        match get_room_type room !(model.matrix_client) with
        | Group ->
            Belt.Map.set acc (Some room) []
        | SubChat group ->
            Belt.Map.update acc (Some group) (function
                | None ->
                    Some (Belt.List.make 1 room)
                | Some chats ->
                    Some (Belt.List.concat chats [ room ]))
        | Chat ->
            Belt.Map.update acc None (function
                | None ->
                    Some (Belt.List.make 1 room)
                | Some chats ->
                    Some (Belt.List.concat chats [ room ])))
  in
  let chat_view room =
    (* let () = Js.log room in *)
    (* let () = Js.log !(model.matrix_client) in *)
    li
      ~unique:room##roomId
      []
      [ Router.link
          goTo
          (Chat (Id room##roomId)) (* XXX *)
          [ div
              [ classList
                  [ ("chat_link", true); ("active", equal_to_room room route) ]
              ]
              [ text room##name ]
          ]
      ]
  in
  let group_view (group, chats) =
    match group with
    | Some g ->
        li
          ~unique:g##roomId
          []
          [ Router.link
              goTo
              (Group (Id g##roomId))
              (* XXX *)
              [ div
                  [ classList
                      [ ("group_link", true)
                      ; ("active", equal_to_room g route)
                      ]
                  ]
                  [ text g##name
                  ; Router.link
                      ~props:
                        [ class' "create_chat_link"
                        ; Icons.aria_label (T.sidebar_new_chat ())
                        ; title (T.sidebar_new_chat ())
                        ]
                      goTo
                      (CreateChat (Some g##roomId))
                      [ Icons.icon "plus" ]
                  ]
              ]
          ; ul [] (Belt.List.map chats chat_view)
          ]
    | None ->
        li
          ~unique:"no group"
          []
          [ div
              [ class' "group_link" ]
              [ span [] [ text (T.sidebar_outside_groups ()) ]
              ; Router.link
                  ~props:
                    [ class' "create_chat_link"
                    ; Icons.aria_label (T.sidebar_new_chat ())
                    ; title (T.sidebar_new_chat ())
                    ]
                  goTo
                  (CreateChat None)
                  [ Icons.icon "plus" ]
              ]
          ; ul [] (Belt.List.map chats chat_view)
          ]
  in
  ul
    []
    (* (rooms *)
    (* |. Belt.Array.map room_view *)
    (* |> Belt.List.fromArray) *)
    (Belt.Map.toList rooms_t |. Belt.List.map group_view)


let view route model =
  let open Tea.Html in
  div
    [ id "sidebar"
    ; classList
        [ ("visible", model.show_menu)
        ]
    ]
    ( if Auth.is_logged_in model.matrix_client
    then
      [ Router.link
          ~props:[ class' "button pill" ]
          goTo
          Router.CreateGroup
          [ text (T.sidebar_create_group ()) ]
      ; room_list_view route model
      ]
    else
      [] )
