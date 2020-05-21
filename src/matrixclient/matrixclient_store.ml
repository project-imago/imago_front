type user

type storage

type group

type filter

type account_data

type t =
  < accountData : account_data
  ; filters : filter Js.Dict.t
  ; groups : group Js.Dict.t
  ; localStorage : storage
  ; rooms : Matrixclient_room.t Js.Dict.t
  ; users : user Js.Dict.t >
  Js.t
