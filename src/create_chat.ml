type model =
  { matrix_client : Matrix.client ref
  ; name : string
  ; topic : string
  ; group : Matrix.room_id option
  }

let init matrix_client = { matrix_client; name = ""; topic = ""; group = None }

type msg =
  | GoTo of Router.route
  | SaveName of string
  | SaveTopic of string
  | CreateChat of Matrix.room_id option
  | CreatedChat of
      Matrix.room_id option * (Matrix.create_room_response, string) Tea.Result.t
  | SentChatEvents of (string array, string) Tea.Result.t
[@@bs.deriving { accessors }]

let create_group_cmd model maybe_group =
  (* let group = Group.create_group model.statements in *)
  (* Tea.Cmd.msg (GoTo group) *)
  (* Tea.Cmd.msg (GoTo Index) *)
  Js.log (Belt.Option.getWithDefault maybe_group "no parent group") ;
  let options : Matrix.create_room_options =
    [%bs.obj
      { invite = [||]
      ; name = model.name
      ; room_alias_name = None
      ; topic = model.topic
      ; visibility = "public"
      }]
  in
  !(model.matrix_client)##createRoom options
  |. Tea_promise.result (createdChat maybe_group)


let send_group_events_cmd model room_id maybe_group =
  let maybe_have_group =
    match maybe_group with
    | Some group ->
        [| Matrix.sendStateEventId
             !(model.matrix_client)
             room_id
             "pm.imago.group"
             [%bs.obj { id = group }]
             ""
        |]
    | None ->
        [||]
  in
  maybe_have_group
  |. Belt.Array.concat
       [| Matrix.sendStateEventType
            !(model.matrix_client)
            room_id
            "pm.imago.type"
            [%bs.obj { _type = "chat" }]
            ""
       |]
  |> Js.Promise.all
  |. Tea_promise.result sentChatEvents


(* TODO: add related group *)

let update model = function
  | GoTo _ ->
      (model, Tea.Cmd.none)
  | SaveName name ->
      ({ model with name }, Tea.Cmd.none)
  | SaveTopic topic ->
      ({ model with topic }, Tea.Cmd.none)
  | CreateChat maybe_group ->
      (* {model with group = maybe_group}, *)
      (model, create_group_cmd model maybe_group)
      (* TODO: add room_id in state to use for edit chat *)
  | CreatedChat (maybe_group, Tea.Result.Ok res) ->
      ( model
      , Tea.Cmd.batch
          [ send_group_events_cmd model res##room_id maybe_group
          ; Tea.Cmd.msg (goTo (Chat res##room_id))
          ] )
  | CreatedChat (_maybe_group, Tea.Result.Error err) ->
      Js.Exn.raiseError "erreur" |> ignore ;
      let () = Js.log ("create group failed: " ^ err) in
      (model, Tea.Cmd.none)
  | SentChatEvents (Tea.Result.Ok res) ->
      Js.log res ;
      (model, Tea.Cmd.none)
  | SentChatEvents (Tea.Result.Error err) ->
      Js.log err ;
      (model, Tea.Cmd.none)


let form_view model maybe_group =
  let group = Belt.Option.getWithDefault maybe_group "" in
  let () = Js.log group in
  let open Tea.Html in
  let onSubmit ?(key = "") msg =
    Tea.Html2.Events.preventDefaultOn
      ~key
      "submit"
      (Tea_json.Decoder.succeed msg)
  in
  form
    ~unique:(Belt.Option.getWithDefault maybe_group "")
    [ onSubmit (createChat maybe_group) ]
    [ fieldset
        []
        [ label [ for' "name-field" ] [ text "Name" ]
        ; input'
            [ type' "text"; id "name-field"; onInput saveName ]
            [ text model.name ]
        ; label [ for' "topic-field" ] [ text "Topic" ]
        ; input'
            [ type' "text"; id "topic-field"; onInput saveTopic ]
            [ text model.topic ]
        ; button [ type' "submit" ] [ text "Send" ]
        ]
    ]


let view model maybe_group =
  let open Tea.Html in
  div ~unique:"create_chat" [ id "create-chat" ] [ form_view model maybe_group ]
