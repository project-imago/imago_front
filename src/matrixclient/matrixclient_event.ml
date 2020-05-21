type event_id = string

type event_content = < body : string ; msgtype : string > Js.t

type event =
  < content : event_content
  ; event_id : event_id
  ; origin_server_ts : int
  ; room_id : Matrixclient_common.room_id
  ; sender : Matrixclient_common.user_id >
  Js.t

type matrix_event =
  < error : string Js.Nullable.t
  ; event : event
  ; forwardLooking : bool
  ; sender : Matrixclient_room_member.t
  ; status : string Js.Nullable.t
  ; target : string Js.Nullable.t >
  Js.t
