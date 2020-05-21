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


module TypeState = Client.MakeStateAccessors (struct
  type t = < _type : string > Js.t
end)

module IdState = Client.MakeStateAccessors (struct
  type t = < id : Matrixclient_common.room_id > Js.t
end)

module StatementState = Client.MakeStateAccessors (struct
  type t = < objects : string array > Js.t
end)
