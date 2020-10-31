type scroll_position = Up | Middle | Down

type msg =
  | GoTo of Router.route
  | SetCurrentRoom of Matrix.room_id
  | GotRoomId of (< room_id : string > Js.t, string) Tea.Result.t
  | Peeked of (Matrix.room, string) Tea.Result.t
  | SaveMessage of Matrix.room_id * string
  | SendMessage of Matrix.room_id * string
  | SentMessage of (< event_id : string > Js.t, string) Tea.Result.t
  | GotMessage of Matrix.matrix_event * Matrix.room Js.Nullable.t
  | Scrolled of scroll_position
  | PaginatedBackwards of (bool, string) Tea.Result.t
[@@bs.deriving { accessors }]

type model =
  { new_messages : string Js.Dict.t
  ; scrolled_positions : scroll_position Js.Dict.t
  ; current_room : Matrix.room option
  ; (* current_room : Matrix.room option; *)
    matrix_client : Matrix.client ref
  }

let init matrix_client =
  { current_room = None
  ; matrix_client
  ; new_messages = Js.Dict.empty ()
  ; scrolled_positions = Js.Dict.empty ()
  }


let subscriptions model =
  Matrix.Client.subscribe_to_timeline !(model.matrix_client) gotMessage


let send_message_cmd client room_id message =
  let content : Matrix.event_content =
    [%bs.obj { body = message; msgtype = "m.room.message" }]
  in
  Tea_promise.result (client##sendMessage room_id content) sentMessage


let peek_room_cmd model room_id =
  Tea_promise.result (!(model.matrix_client)##peekInRoom room_id) peeked


let resolve_alias_cmd model room_alias =
  Tea_promise.result
    (!(model.matrix_client)##resolveRoomAlias room_alias)
    gotRoomId


let set_chat_room model = function
  | Matrix.Id room_id ->
      Tea.Cmd.msg (SetCurrentRoom room_id)
  | Alias room_alias ->
      resolve_alias_cmd model room_alias


type html_element =
  < scrollTop : int [@bs.set] ; clientHeight : int ; scrollHeight : int > Js.t

let scrolled_down_element element =
  element##scrollTop + element##clientHeight = element##scrollHeight


let scroll_down_element ?(offset=None) element =
  match offset with
  | None ->
      element ## scrollTop #= (element##scrollHeight - element##clientHeight)
  | Some o ->
      element ## scrollTop #= (element##scrollHeight - o)

let scrolled_position_element element =
  match element##scrollTop with
  | 0 -> Up
  | n when n = (element##scrollHeight - element##clientHeight) -> Down
  | _ -> Middle

external get_element_by_id : string -> html_element Js.Nullable.t
  = "getElementById"
  [@@bs.scope "document"] [@@bs.val]

(* let scroll_down_cmd = *)
(*   Js.log "scrolling_down"; *)
(*   Tea.Cmd.none *)

let current_height () =
  match
    get_element_by_id "message-list" |> Js.Nullable.toOption
  with
  | Some elm ->
      Some elm##scrollHeight
  | None ->
      None

let timeout_scroll_down ?(offset=None) ?(time=100.0) () =
  Web.Window.setTimeout
    (fun () ->
      let () =
        match
          get_element_by_id "message-list" |> Js.Nullable.toOption
        with
        | Some elm ->
            scroll_down_element ~offset elm
        | None ->
            ()
      in
      ())
    time

let scroll_down_cmd =
  Tea_cmd.call (fun _enqueue ->
      let _ = timeout_scroll_down ()
      in
      ())

let first_scroll_down model room =
  match Js.Dict.get model.scrolled_positions room##roomId with
  | Some Down | None -> scroll_down_cmd 
  | Some _ -> Tea.Cmd.none

let paginate_backwards_cmd model room =
  let live_timeline = room##getLiveTimeline () in
  let opts = [%bs.obj {backwards = true; limit = 20}] in
  !(model.matrix_client)##paginateEventTimeline live_timeline opts
  |> Js.Promise.then_ (fun result ->
      let _ = timeout_scroll_down ~offset:(current_height ()) () in
      Js.Promise.resolve result)
  |. Tea_promise.result paginatedBackwards

let update model = function
  | GoTo _ ->
      (model, Tea.Cmd.none)
  | SetCurrentRoom room_id ->
      let room_in_store =
        !(model.matrix_client)##getRoom room_id |> Js.Nullable.toOption
      in
      ( match room_in_store with
      | Some room ->
          ({ model with current_room = Some room }, first_scroll_down model room)
      | None ->
          (model, peek_room_cmd model room_id) )
  | GotRoomId (Tea.Result.Ok res) ->
      (model, Tea.Cmd.msg (SetCurrentRoom res##room_id))
  | GotRoomId (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)
  | Peeked (Tea.Result.Ok room) ->
      ({ model with current_room = Some room }, first_scroll_down model room)
  | Peeked (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)
  | SaveMessage (room_id, message) ->
      Js.Dict.set model.new_messages room_id message ;
      (model, Tea.Cmd.none)
  | SendMessage (room_id, message) ->
      Js.Dict.set model.new_messages room_id "" ;
      let cmd = send_message_cmd !(model.matrix_client) room_id message in
      (model, cmd)
  | SentMessage (Tea.Result.Ok res) ->
      let () = Js.log res in
      (model, Tea.Cmd.none)
  | SentMessage (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)
  | GotMessage (event, nullable_room) ->
      (* let () = Js.log event in *)
      let cmd =
        match
          ( model.current_room
          , nullable_room |> Js.Nullable.toOption
          , event##getType () )
        with
        | Some current_room, Some event_room, "m.room.message"
          when current_room = event_room
               && Js.Dict.get model.scrolled_positions current_room##roomId
                  = Some Down ->
            scroll_down_cmd
        | _ ->
            Tea.Cmd.none
      in
      (model, cmd)
  | Scrolled b ->
      let cmd =
        match model.current_room with
        | Some room ->
            Js.Dict.set model.scrolled_positions room##roomId b;
            (match b with
            | Up -> paginate_backwards_cmd model room
            | _ -> Tea.Cmd.none)
        | None ->
            Tea.Cmd.none
      in
      (* Js.log model.scrolled_positions ; *)
      (model, cmd)
  | PaginatedBackwards (Tea.Result.Ok res) ->
      let () = Js.log res in
      (model, Tea.Cmd.none)
  | PaginatedBackwards (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)


let string_of_option = function Some str -> str | None -> ""

let on_ctrl_enter ?(key = "") msg =
  let open Tea.Html in
  onCB "keydown" key (fun ev ->
      match Js.Undefined.toOption ev##target with
      | None ->
          None
      | Some target ->
        ( match Js.Undefined.toOption target##value with
        | None ->
            None
        | Some value ->
            if ev##keyCode = 13 && [%raw {|ev.ctrlKey|}]
            then Some (msg value)
            else None ))


let on_scroll_up ?(key = "") msg =
  let open Tea.Html in
  onCB "scroll" key (fun ev ->
      match Js.Undefined.toOption ev##target with
      | None ->
          None
      | Some target ->
        ( match scrolled_position_element (Obj.magic target) with
        | Down ->
            Some (msg Down)
        | Middle ->
            Some (msg Middle)
        | Up ->
            Some (msg Up) ))


let get_messages room =
  (room##getLiveTimeline ())##getEvents ()
  |. Belt.Array.keep (fun _matrix_event ->
         [%raw {|_matrix_event.event.type|}] = "m.room.message")


let message_view matrix_event =
  (* Js.log matrix_event; *)
  let open Tea.Html in
  (* let message_display = *)
  (*   Printf.sprintf *)
  (*     "<%s> %s" *)
  (*     matrix_event##sender##rawDisplayName *)
  (*     matrix_event##event##content##body *)
  (* in *)
  let date = matrix_event##getDate () in
  let iso_date = Js.Date.toISOString date in

  div
    [ class' "message"; id (matrix_event##getId ()) ]
    [ span
        [ class' "message-sender" ]
        [ text matrix_event##sender##rawDisplayName ]
    ; time
        [ class' "message-date"; Vdom.prop "datetime" iso_date ]
        [ text (T.chat_message_date { date }) ]
    ; div [ class' "message-body" ] [ text (matrix_event##getContent ())##body ]
    ]


let input_area model room_id =
  let open Tea.Html in
  let new_message_value model room_id =
    Js.Dict.get model.new_messages room_id |> string_of_option
  in
  textarea
    [ value (new_message_value model room_id)
    ; on_ctrl_enter ~key:room_id (sendMessage room_id)
    ; onInput ~key:room_id (saveMessage room_id)
    ]
    [ text "" ]


let view model =
  let open Tea.Html in
  match model.current_room with
  | Some room ->
      let message_list =
        get_messages room |. Belt.Array.map message_view |> Belt.List.fromArray
      in
      div
        ~unique:"chat"
        [ id "chat-view" ]
        [ div [ id "chat-header" ]
          [ h3 [] [ text room##name ]
          ; Icons.icon "ellipsis-vertical"]
        ; div
            ~unique:room##roomId
            [ id "message-list"; on_scroll_up scrolled ]
            message_list
        ; div
            ~unique:room##roomId
            [ id "input-area" ]
            [ input_area model room##roomId ]
        ]
  | None ->
      div [ id "room-view" ] [ text (T.chat_room_not_found ()) ]

(* let view model = function *)
(*   | Router.Room _ -> *)
(*       match model.current_room with *)
(*       | Some room -> room_view room (Js.Dict.get model.new_messages room##roomId |> *)
(*       string_of_option) *)
(*       | None -> Tea.Html.div [] [] *)
