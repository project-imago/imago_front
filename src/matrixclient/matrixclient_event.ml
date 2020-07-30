type event_id = string

type event_content = < body : string ; msgtype : string > Js.t

type event =
  < content : event_content
  ; event_id : event_id
  ; origin_server_ts : float
  ; room_id : Matrixclient_common.room_id
  ; sender : Matrixclient_common.user_id >
  Js.t

type matrix_event =
  < error : string Js.Nullable.t
  (* ; event : event *) (* should not be used *)
  ; forwardLooking : bool
  ; sender : Matrixclient_room_member.t
  ; status : string Js.Nullable.t
  ; target : string Js.Nullable.t
  ; getId : unit -> event_id [@bs.meth]
  ; getSender : unit -> Matrixclient_common.user_id [@bs.meth]
  ; getType : unit -> string [@bs.meth]
  ; getWireType : unit -> string [@bs.meth]
  ; getRoomId : unit -> Matrixclient_common.room_id Js.Undefined.t [@bs.meth]
  ; getTs : unit -> int [@bs.meth]
  ; getDate : unit -> Js.Date.t [@bs.meth]
  ; getOriginalContent : unit -> event_content [@bs.meth]
  ; getContent : unit -> event_content [@bs.meth]
  ; getWireContent : unit -> event_content [@bs.meth]
  ; getPrevContent : unit -> event_content [@bs.meth]
  ; getAge : unit -> int [@bs.meth]
  ; getLocalAge : unit -> int [@bs.meth]
  ; getStateKey : unit -> string Js.Undefined.t [@bs.meth]
  ; isState : unit -> bool [@bs.meth] >
  Js.t
