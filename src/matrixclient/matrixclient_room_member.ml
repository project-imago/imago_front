type matrix_event2

type t =
  < events : matrix_event2 Js.Dict.t
  ; membership : string
  ; name : string
  ; powerLevel : int
  ; powerLevelNorm : int
  ; rawDisplayName : string
  ; roomId : Matrixclient_common.room_id
  ; typing : bool
  ; user : string Js.Null.t
  ; userId : Matrixclient_common.user_id >
  Js.t
