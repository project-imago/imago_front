type tag

type re_emitter

type account_data

type room_summary =
  < info : < title : string > Js.t ; roomId : Matrixclient_common.room_id > Js.t

type timeline = Matrixclient_event.matrix_event array

type event_timeline = < getEvents : unit -> timeline [@bs.meth] > Js.t

type t =
  < accountData : account_data
  ; currentState : Matrixclient_room_state.t
  ; myUserId : Matrixclient_common.user_id
  ; name : string
  ; oldState : Matrixclient_room_state.t
  ; reEmitter : re_emitter
  ; roomId : Matrixclient_common.room_id
  ; storageToken : string Js.Undefined.t
  ; summary : room_summary
  ; tags : tag Js.Dict.t
  ; timeline : timeline
  ; getLiveTimeline : unit -> event_timeline [@bs.meth] >
  Js.t
