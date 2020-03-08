type user_id =      string
type room_id =      string
type access_token = string
type home_server =  string
type device_id =    string
type login_map =    string Js.Dict.t
type re_emitter
type room_state
type group
type data
type filter
type account_data
type event_emitter
type storage
type user
type tag
type event_id = string
type event_type = string
(* ([ | `room_message [@bs.as "m.room.message"] ] [@bs.string]) *)
type matrix_event2

type room_member =
  < events: matrix_event2 Js.Dict.t;
    membership: string;
    name: string;
    powerLevel: int;
    powerLevelNorm: int;
    rawDisplayName: string;
    roomId: room_id;
    typing: bool;
    user: string Js.Null.t;
    userId: user_id;
  > Js.t

type event_content =
  < body: string;
    msgtype: string;
  > Js.t

type event =
  < content: event_content;
    event_id: event_id;
    origin_server_ts: int;
    room_id: room_id;
    sender: user_id;
  > Js.t

type matrix_event =
  < error: string Js.Nullable.t;
    event: event;
    forwardLooking: bool;
    sender: room_member;
    status: string Js.Nullable.t;
    target: string Js.Nullable.t;
  > Js.t

type timeline =      matrix_event array

type event_timeline =
  < getEvents:  unit -> timeline [@bs.meth];
  > Js.t

type room_summary =
  < info : < title : string > Js.t;
    roomId : room_id;
  > Js.t

type room =
  < accountData:  account_data;
    currentState: room_state;
    myUserId:     user_id;
    name:         string;
    oldState:     room_state;
    reEmitter:    re_emitter;
    roomId:       room_id;
    storageToken: string Js.Undefined.t;
    summary:      room_summary;
    tags:         tag Js.Dict.t;
    timeline:     timeline;
    getLiveTimeline:     unit -> event_timeline [@bs.meth];
  > Js.t

type store =
  < accountData:  account_data;
    filters:      filter Js.Dict.t;
    groups:       group Js.Dict.t;
    localStorage: storage;
    rooms:        room Js.Dict.t;
    users:        user Js.Dict.t;
  > Js.t

type login_response =
  < user_id:      user_id;
    access_token: access_token;
    home_server:  home_server;
    device_id:    device_id;
  > Js.t

type client =
  < credentials:    < userId : user_id > Js.t;
    clientRunning:  bool;
    getAccessToken: unit
                    -> access_token [@bs.meth];
    login:          string
                    -> string Js.Dict.t
                    -> login_response Js.Promise.t [@bs.meth];
    logout:         unit
                    -> string Js.Dict.t [@bs.meth];
    (*on:             string -> ([ | `test of event -> room -> bool -> bool -> data -> unit
                               ] [@bs.string]) -> event_emitter [@bs.meth];*)
    getJoinedRooms: unit
                    -> (<joined_rooms: room_id array> Js.t) Js.Promise.t [@bs.meth];
    sendMessage:    room_id
                    -> event_content
                    -> string Js.Promise.t [@bs.meth];
    store:          store;
  > Js.t

external start_client:
  client
  -> unit
  = "startClient" [@@bs.send]

external on:
  client
  -> ([
      | `timeline of
        event
        -> room
        -> bool
        -> bool
        -> data
        -> unit
      [@bs.as "Room.timeline"] ]
      [@bs.string])
  -> event_emitter 
  = "on" [@@bs.send]

external off:
  client
  -> ([
      | `timeline of
        event
        -> room
        -> bool
        -> bool
        -> data
        -> unit
      [@bs.as "Room.timeline"] ]
      [@bs.string])
  -> event_emitter 
  = "off" [@@bs.send]

external once:
  client
  -> ([ | `sync of
          string
          -> string
          -> string
          -> unit
      ] [@bs.string])
  -> event_emitter
  = "once" [@@bs.send]

external create_client:
  string
  -> client
  = "createClient" [@@bs.module "matrix-js-sdk"]

external create_client_params:
  string Js.Dict.t
  -> client
  = "createClient" [@@bs.module "matrix-js-sdk"]


let get_joined_rooms client =
  client##getJoinedRooms ()
  |> Js.Promise.then_ (fun res ->
      res##joined_rooms
      |> Belt.List.fromArray
      |> Js.Promise.resolve
  )

let subscribe client tagger =
  let open Vdom in
  let enableCall callbacks =
    let args = (`timeline (fun event _room _toStartOfTimeline _removed _data ->
          callbacks.enqueue (tagger event))) in
    let _ = on client args in
    fun () ->
      let _ = off client args in
      ()
  in Tea_sub.registration "test" enableCall

let subscribe_once client tagger =
  let open Vdom in
  let enableCall callbacks =
    let args = (`sync (fun state _prevState _data ->
          callbacks.enqueue (tagger state))) in
    let _ = once client args in
    fun () ->
      ()
  in Tea_sub.registration "sync" enableCall

let new_client () =
  create_client "https://matrix.imago.local:8448"

let new_client_params matrix_id access_token =
  let login_map = Js.Dict.empty () in
  let () = Js.Dict.set login_map "baseUrl"  "https://matrix.imago.local:8448" in
  let () = Js.Dict.set login_map "accessToken" access_token in
  let () = Js.Dict.set login_map "userId" matrix_id in
  create_client_params login_map

let login client =
  let login_map = Js.Dict.empty () in
  let () = Js.Dict.set login_map "user" "alice" in
  let () = Js.Dict.set login_map "password" "imago42imago" in
  client##login "m.login.password" login_map


let logout client =
  client##logout ()
