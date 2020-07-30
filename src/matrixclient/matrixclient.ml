module Common = Matrixclient_common
module Event = Matrixclient_event
module Room = Matrixclient_room
module RoomMember = Matrixclient_room_member
module RoomState = Matrixclient_room_state
module Store = Matrixclient_store

type user_id = string

type access_token = string

type home_server = string

type device_id = string

type login_map = string Js.Dict.t

type data

type event_emitter

type event_type = string

(* ([ | `room_message [@bs.as "m.room.message"] ] [@bs.string]) *)

type login_response =
  < user_id : user_id
  ; access_token : access_token
  ; home_server : home_server
  ; device_id : device_id >
  Js.t

type create_room_options =
  < room_alias_name : string option
  ; visibility : string
  ; (* either public or private *)
      invite : user_id array
  ; name : string
  ; topic : string >
  Js.t

type create_room_response =
  < room_id : Matrixclient_common.room_id ; room_alias : string option > Js.t

type client_config_part =
  < base_url : string Js.Nullable.t
  ; error : string Js.Nullable.t
  ; state : string >
  Js.t

type client_config = client_config_part Js.Dict.t

type auto_discovery =
  < findClientConfig : string -> client_config Js.Promise.t [@bs.meth] > Js.t

type paginate_opts = < backwards : bool; limit : int > Js.t

type client =
  < credentials : < userId : user_id > Js.t
  ; clientRunning : bool
  ; getAccessToken : unit -> access_token [@bs.meth]
  ; login : string -> string Js.Dict.t -> login_response Js.Promise.t [@bs.meth]
  ; loginWithPassword : string -> string -> login_response Js.Promise.t [@bs.meth
                                                                          ]
  ; register :
         string
      -> string
      -> string option
      -> [%bs.obj: < session : string ; _type : string > ] option
      -> login_response Js.Promise.t [@bs.meth]
  ; logout : unit -> string Js.Dict.t [@bs.meth]
  ; isLoggedIn : unit -> bool [@bs.meth]
  ; createRoom : create_room_options -> create_room_response Js.Promise.t [@bs.meth
                                                                            ]
  ; getUserId : unit -> user_id [@bs.meth]
  ; getUser : user_id -> Matrixclient_user.t Js.Nullable.t [@bs.meth]
  ; getJoinedRooms :
         unit
      -> < joined_rooms : Matrixclient_common.room_id array > Js.t Js.Promise.t [@bs.meth
                                                                                ]
  ; sendMessage :
         Matrixclient_common.room_id
      -> Matrixclient_event.event_content
      -> < event_id : string > Js.t Js.Promise.t [@bs.meth]
  ; store : Matrixclient_store.t
  ; getRoom : Matrixclient_common.room_id -> Matrixclient_room.t Js.Nullable.t [@bs.meth
                                                                                ]
  ; resolveRoomAlias :
      Matrixclient_common.room_id -> < room_id : string > Js.t Js.Promise.t [@bs.meth
                                                                              ]
  ; peekInRoom : Matrixclient_common.room_id -> Matrixclient_room.t Js.Promise.t 
        [@bs.meth]
  ; _AutoDiscovery : auto_discovery
  ; paginateEventTimeline : Matrixclient_room.event_timeline -> paginate_opts ->
    bool Js.Promise.t [@bs.meth] >
  Js.t

external matrixcs : client = "matrixcs" [@@bs.val]

external start_client : client -> unit = "startClient" [@@bs.send]

external start_client : client -> unit = "startClient" [@@bs.send]

external stop_client : client -> unit = "stopClient" [@@bs.send]

(* external sendStateEventStatement : *)
(*      client *)
(*   -> Matrixclient_common.room_id *)
(*   -> string (1* event type *1) *)
(*   -> [%bs.obj: < objects : string array > ] (1* can be anything *1) *)
(*   -> string (1* state key *1) *)
(*   -> string Js.Promise.t = "sendStateEvent" *)
(*   [@@bs.send] *)

(* external sendStateEventType : *)
(*      client *)
(*   -> Matrixclient_common.room_id *)
(*   -> string (1* event type *1) *)
(*   -> [%bs.obj: < _type : string > ] (1* can be anything *1) *)
(*   -> string (1* state key *1) *)
(*   -> string Js.Promise.t = "sendStateEvent" *)
(*   [@@bs.send] *)

(* external sendStateEventId : *)
(*      client *)
(*   -> Matrixclient_common.room_id *)
(*   -> string (1* event type *1) *)
(*   -> [%bs.obj: < id : string > ] (1* can be anything *1) *)
(*   -> string (1* state key *1) *)
(*   -> string Js.Promise.t = "sendStateEvent" *)
(*   [@@bs.send] *)

external on :
     client
  -> ([ `timeline of
           Matrixclient_event.matrix_event
        -> Matrixclient_room.t Js.Nullable.t
        -> bool (* toStartOfTimeLine *)
        -> bool (* removed *)
        -> data
        -> unit[@bs.as "Room.timeline"]
      ]
     [@bs.string])
  -> event_emitter = "on"
  [@@bs.send]

external off :
     client
  -> ([ `timeline of
           Matrixclient_event.matrix_event
        -> Matrixclient_room.t Js.Nullable.t
        -> bool
        -> bool
        -> data
        -> unit[@bs.as "Room.timeline"]
      ]
     [@bs.string])
  -> event_emitter = "off"
  [@@bs.send]

external once :
     client
  -> ([ `sync of
           string (* state *)
        -> string (* prevState *)
        -> string (* data *)
        -> unit
      | `logged_out of string -> unit[@bs.as "Session.logged_out"]
      ]
     [@bs.string])
  -> event_emitter = "once"
  [@@bs.send]

external create_client : string -> client = "createClient"
  [@@bs.module "matrix-js-sdk"]

external create_client_params :
  < baseUrl : string ; userId : string ; accessToken : string > Js.t -> client
  = "createClient"
  [@@bs.module "matrix-js-sdk"]

let get_joined_rooms client =
  client##getJoinedRooms ()
  |> Js.Promise.then_ (fun res ->
         res##joined_rooms |> Belt.List.fromArray |> Js.Promise.resolve)


let subscribe_to_timeline client tagger =
  let open Vdom in
  let enableCall callbacks =
    let args =
      `timeline
        (fun event room _toStartOfTimeline _removed _data ->
          callbacks.enqueue (tagger event room))
    in
    let _ = on client args in
    fun () ->
      let _ = off client args in
      ()
  in
  Tea_sub.registration "Room.timeline" enableCall


let subscribe_once_sync client tagger =
  let open Vdom in
  let enableCall callbacks =
    let args =
      `sync
        (fun state prevState data ->
          callbacks.enqueue (tagger state prevState data))
    in
    let _ = once client args in
    fun () -> ()
  in
  Tea_sub.registration "sync" enableCall


let subscribe_once_logged_out client tagger =
  let open Vdom in
  let enableCall callbacks =
    let args = `logged_out (fun error -> callbacks.enqueue (tagger error)) in
    let _ = once client args in
    fun () -> ()
  in
  Tea_sub.registration "sync" enableCall


(* let new_client_params matrix_id access_token = *)
(*   let login_map = Js.Dict.empty () in *)
(*   let () = Js.Dict.set login_map "baseUrl" "http://matrix.imago.local:8008" in *)
(*   let () = Js.Dict.set login_map "accessToken" access_token in *)
(*   let () = Js.Dict.set login_map "userId" matrix_id in *)
(*   create_client_params login_map *)

let new_client_params base_url user_id access_token =
  let login_map =
    [%bs.obj
      { baseUrl = base_url; accessToken = access_token; userId = user_id }]
  in
  create_client_params login_map


(* let login client username password = *)
(* let login_map = Js.Dict.empty () in *)
(* let () = Js.Dict.set login_map "user" username in *)
(* let () = Js.Dict.set login_map "password" password in *)
(* client##login "m.login.password" login_map *)

let login_with_password client username password =
  client##loginWithPassword username password


(* let login_with_token client token = *)
(*   client##loginWithToken token *)

(* let register client username password = *)
(*   client##register username password *)

let register client username password session_id auth =
  client##register username password session_id auth


let logout client = client##logout ()

let create_room
    ?(invite = [||])
    ?(alias = None)
    ?(visibility = "public")
    ?(topic = "")
    client
    name =
  let options : create_room_options =
    [%bs.obj { invite; name; room_alias_name = alias; topic; visibility }]
  in
  client##createRoom options


module type CustomStateEvent = sig
  type t
end

module MakeStateAccessors (S : CustomStateEvent) = struct
  type event = < state_key : string ; getContent : unit -> S.t [@bs.meth] > Js.t

  external get : RoomState.t -> string -> event array = "getStateEvents"
    [@@bs.send]

  external get_one : RoomState.t -> string -> string -> event Js.Nullable.t
    = "getStateEvents"
    [@@bs.send]

  external send :
       client
    -> Matrixclient_common.room_id
    -> string (* event type *)
    -> S.t (* can be anything *)
    -> string (* state key *)
    -> string Js.Promise.t = "sendStateEvent"
    [@@bs.send]
end
