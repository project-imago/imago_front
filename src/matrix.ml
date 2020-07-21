module Client = Matrixclient

type room_id = Matrixclient.Common.room_id

type room_alias = Matrixclient.Common.room_alias

type client = Matrixclient.client

type room = Matrixclient.Room.t

type event = Matrixclient.Event.event

type event_content = Matrixclient.Event.event_content

type create_room_response = Matrixclient.create_room_response

type login_response = Matrixclient.login_response

type client_config = Matrixclient.client_config

let matrixcs = Matrixclient.matrixcs

type room_address = Id of room_id | Alias of room_alias

let default_server = Config.matrix_url

let create_client () =
  let _ = Js.log default_server in
  Matrixclient.create_client default_server

let create_client_to_server server =
  let _ = Js.log server in
  Matrixclient.create_client server

let new_client_params ?(server=default_server) user_id access_token =
  Matrixclient.new_client_params
    server
    user_id
    access_token

let current_user_name client =
  let user_id = !client##getUserId () in
  let user = !client##getUser user_id in
  Js.Nullable.toOption user
  |. Belt.Option.map
  (function user -> user##displayName)


module TypeState = Client.MakeStateAccessors (struct
  type t = < _type : string > Js.t
end)

module IdState = Client.MakeStateAccessors (struct
  type t = < id : Matrixclient_common.room_id > Js.t
end)
