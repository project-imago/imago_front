module Client = Matrixclient

type room_id = Matrixclient.Common.room_id

type client = Matrixclient.client

type room = Matrixclient.Room.t

type event = Matrixclient.Event.event

type event_content = Matrixclient.Event.event_content

type create_room_response = Matrixclient.create_room_response

type login_response = Matrixclient.login_response

let create_client () =
  Matrixclient.create_client "http://matrix.imago.local:8008"


let new_client_params user_id access_token =
  Matrixclient.new_client_params
    "http://matrix.imago.local:8008"
    user_id
    access_token


type state_type =
  < getContent : unit -> < _type : string > Js.t [@bs.meth] > Js.t

external get_state_type :
  Client.RoomState.t -> (_[@bs.as "pm.imago.type"]) -> state_type array
  = "getStateEvents"
  [@@bs.send]

type state_group =
  < getContent : unit -> < id : Matrixclient_common.room_id > Js.t [@bs.meth] >
  Js.t

external get_state_group :
  Client.RoomState.t -> (_[@bs.as "pm.imago.group"]) -> state_group array
  = "getStateEvents"
  [@@bs.send]

external sendStateEventStatement :
     client
  -> Matrixclient_common.room_id
  -> string (* event type *)
  -> [%bs.obj: < objects : string array > ] (* can be anything *)
  -> string (* state key *)
  -> string Js.Promise.t = "sendStateEvent"
  [@@bs.send]

external sendStateEventType :
     client
  -> Matrixclient_common.room_id
  -> string (* event type *)
  -> [%bs.obj: < _type : string > ] (* can be anything *)
  -> string (* state key *)
  -> string Js.Promise.t = "sendStateEvent"
  [@@bs.send]

external sendStateEventId :
     client
  -> Matrixclient_common.room_id
  -> string (* event type *)
  -> [%bs.obj: < id : string > ] (* can be anything *)
  -> string (* state key *)
  -> string Js.Promise.t = "sendStateEvent"
  [@@bs.send]
