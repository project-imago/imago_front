module Client = Matrixclient

type room_id = Matrixclient.Common.room_id

type room_alias = Matrixclient.Common.room_alias

type client = Matrixclient.client

type room = Matrixclient.Room.t

type event = Matrixclient.Event.event

type event_content = Matrixclient.Event.event_content

type create_room_response = Matrixclient.create_room_response

type login_response = Matrixclient.login_response

type room_address = Id of room_id | Alias of room_alias

let default_server = Config.matrix_url

let create_client () =
  let _ = Js.log default_server in
  Matrixclient.create_client default_server


let new_client_params user_id access_token =
  Matrixclient.new_client_params
    default_server
    user_id
    access_token


module TypeState = Client.MakeStateAccessors (struct
  type t = < _type : string > Js.t
end)

module IdState = Client.MakeStateAccessors (struct
  type t = < id : Matrixclient_common.room_id > Js.t
end)
