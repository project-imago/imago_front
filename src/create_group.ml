type model =
  { matrix_client : Matrix.client ref
  ; name : string
  ; topic : string
  ; (* statements : (property * obj) array; *)
    (* statements : (obj array) Belt.Map.String.t; *)
    statements : Statements.t
  ; property_search : string
  ; property_suggestions : Statements.property array
  ; property_selected : string option
  ; obj_search : string
  ; obj_suggestions : Statements.obj array
  ; obj_selected : Statements.obj option
  }

let init matrix_client =
  { matrix_client
  ; name = ""
  ; topic = ""
  ; statements = Statements.empty
  ; property_search = "img:location"
  ; property_suggestions = [| "img:location"; "img:subgroup"; "img:about" |]
  ; property_selected = None
  ; obj_search = ""
  ; obj_suggestions = [||]
  ; obj_selected = None
  }


type msg =
  | GoTo of Router.route
  | SaveName of string
  | SaveTopic of string
  | SavePropertySearch of string
  | SelectProperty of string
  | SaveObjSearch of string
  | SelectObj of string
  | ReceivedObjResults of
      (string * Statements.obj array, string Tea.Http.error) Tea.Result.t
  | AddStatement
  | RemoveObj of string * Statements.obj
  | CreateGroup
  | CreatedGroup of (Matrix.create_room_response, string) Tea.Result.t
  | SentGroupEvents of (string array, string) Tea.Result.t
[@@bs.deriving { accessors }]

(* TODO: rename module so its used for create and edit *)
(* TODO: add create/edit room *)

let obj_search_cmd property obj =
  let open Tea.Http in
  let url =
    "http://api.imago.local:4000/obj/search"
    ^ "?property="
    ^ property
    ^ "&term="
    ^ obj
  in
  let decode_response =
    let open Tea.Json.Decoder in
    (* decodeString (list string) json *)
    (* map (fun ) *)
    map2
      (fun a b -> (a, b))
      (field "term" string)
      (field
         "results"
         (array
            (map3
               (fun a b c ->
                 ({ item = a; label = b; description = c } : Statements.obj))
               (field "item" string)
               (field "label" string)
               (field "description" string))))
    |> decodeValue
  in
  let handle_response response =
    let { status; body; _ } = response in
    if status.code <> 200
    then Tea_result.Error status.message
    else
      match body with
      | JsonResponse json ->
          decode_response json
      | _ ->
          assert false
  in
  request
    { method' = "GET"
    ; headers = []
    ; url
    ; body = Web.XMLHttpRequest.EmptyBody
    ; expect = Expect (JsonResponseType, handle_response)
    ; timeout = None
    ; withCredentials = false
    }
  |> send receivedObjResults


(* TODO: debounce, maybe cache *)
(* |> toTask *)

let create_group_cmd model =
  (* let group = Group.create_group model.statements in *)
  (* Tea.Cmd.msg (GoTo group) *)
  (* Tea.Cmd.msg (GoTo Index) *)
  Matrix.Client.create_room !(model.matrix_client) model.name
  ~topic:model.topic
  |. Tea_promise.result createdGroup


(* |> Js.Promise.then_ (fun result -> *)
(*     !(model.matrix_client)##sendStateEvent result##room_id *)
(*     "pm.imago.groups.statement" {objects = objects} property *)
(*     ) *)

let send_group_events_cmd model room_id =
  model.statements
  |> Belt.Map.toArray
  |. Belt.Array.map (fun (property, obj_array) ->
         let obj_items = Belt.Array.map obj_array (fun o -> o.item) in
         Matrix.StatementState.send
           !(model.matrix_client)
           room_id
           "pm.imago.groups.statement"
           [%bs.obj { objects = obj_items }]
           property)
  |. Belt.Array.concat
       [| Matrix.TypeState.send
            !(model.matrix_client)
            room_id
            "pm.imago.type"
            [%bs.obj { _type = "group" }]
            ""
       |]
  |> Js.Promise.all
  |. Tea_promise.result sentGroupEvents


(* !(model.matrix_client)##sendStateEvent room_id *)
(* "pm.imago.groups.statement" {objects = objects} property *)

let update model = function
  | GoTo _ ->
      (model, Tea.Cmd.none)
  | SaveName name ->
      ({ model with name }, Tea.Cmd.none)
  | SaveTopic topic ->
      ({ model with topic }, Tea.Cmd.none)
  | SavePropertySearch property ->
      ({ model with property_search = property }, Tea.Cmd.none)
  | SelectProperty property ->
      ({ model with property_selected = Some property }, Tea.Cmd.none)
  | SaveObjSearch obj ->
      let cmd =
        match model.property_selected with
        | None ->
            Tea.Cmd.none
        | Some property ->
            obj_search_cmd property obj
      in
      ({ model with obj_search = obj }, cmd)
  | SelectObj obj_item ->
      let obj =
        Belt.Array.getBy model.obj_suggestions (fun x -> x.item == obj_item)
      in
      ({ model with obj_selected = obj }, Tea.Cmd.none)
  | ReceivedObjResults (Error err) ->
      Js.log err ;
      (model, Tea.Cmd.none)
  | ReceivedObjResults (Ok (term, results)) ->
      let model =
        if term == model.obj_search
        then { model with obj_suggestions = results }
        else model
      in
      (model, Tea.Cmd.none)
  | AddStatement ->
      Js.log model.property_selected ;
      Js.log model.obj_selected ;
      let new_statements =
        match (model.property_selected, model.obj_selected) with
        | Some property, Some obj ->
            Belt.Map.update model.statements property (function
                | None ->
                    Some (Belt.Array.make 1 obj)
                | Some objs ->
                    Some (Belt.Array.concat objs [| obj |]))
        | _ ->
            model.statements
      in
      ( { model with
          statements =
            new_statements
            (* property_selected = None; *)
            (* obj_selected = None; *)
        }
      , Tea.Cmd.none )
  | RemoveObj (property, obj) ->
      let new_statements =
        Belt.Map.update model.statements property (function
            | None ->
                None
            | Some objs ->
                Some (Belt.Array.keep objs (fun x -> x <> obj)))
      in
      ({ model with statements = new_statements }, Tea.Cmd.none)
  | CreateGroup ->
      (model, create_group_cmd model)
  | CreatedGroup (Tea.Result.Ok res) ->
      ( model
      , (* TODO: add room_id in state to use for edit group *)
        Tea.Cmd.batch
          [ send_group_events_cmd model res##room_id
          ; Tea.Cmd.msg (goTo (Group res##room_id))
          ] )
  | CreatedGroup (Tea.Result.Error err) ->
      Js.Exn.raiseError "erreur" |> ignore ;
      let () = Js.log ("create group failed: " ^ err) in
      (model, Tea.Cmd.none)
  | SentGroupEvents (Tea.Result.Ok res) ->
      Js.log res ;
      (model, Tea.Cmd.none)
  | SentGroupEvents (Tea.Result.Error err) ->
      Js.log err ;
      (model, Tea.Cmd.none)


let statement_list_view model =
  let open Tea.Html in
  let obj_view property (obj : Statements.obj) =
    div
      [ id "object-item" ]
      [ span [] [ text (obj.label ^ " (" ^ obj.description ^ ")") ]
      ; button
          [ onClick (removeObj property obj)
          ; class' "icon"
          ; Icons.aria_label "Remove statement"
          ]
          [ Icons.icon "trash" ]
      ]
  in
  let statement_view (property, objs) =
    div
      [ id "statement-item" ]
      [ div [ id "property-item" ] [ text property ]
      ; div
          [ id "objects-list" ]
          (Belt.Array.map objs (obj_view property) |> Belt.List.fromArray)
      ]
    (* text (property ^ ": " ^ obj) *)
  in
  div
    [ id "statements-list" ]
    (Belt.Map.toList model.statements |. Belt.List.map statement_view)


(* (Belt.Array.map model.statements statement_view *)
(* |> Belt.List.fromArray) *)

let statement_form_view model =
  let open Tea.Html in
  let property_option property = option' [] [ text property ] in
  (* TODO: add selected for what is really selected *)
  let is_obj_selected model obj =
    match model.obj_selected with
    | Some s_obj when s_obj == obj ->
        true
    | _ ->
        false
  in
  (* let selected b = *)
  (*   let open Vdom in *)
  (*   if b then attribute "" "selected" "true" else attribute "" "selected" "false" *)
  (* in *)
  let obj_option (obj : Statements.obj) =
    option'
      [ value obj.item; Attributes.selected (is_obj_selected model obj) ]
      [ text (obj.label ^ " (" ^ obj.description ^ ")") ]
  in
  (* TODO: add selected for what is really selected *)
  form
    [ Tea.Html2.Events.onSubmit createGroup ]
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
        ]
    ; statement_list_view model
    ; div
        [ id "statement-fields" ]
        (* wanted to use fieldset but chromium bug 375693, maybe nest fieldset in div *)
        [ div
            [ id "property-fields" ]
            [ label [ for' "property-search-field" ] [ text "Property" ]
            ; input'
                [ type' "text"
                ; id "property-search-field"
                ; onInput savePropertySearch
                ]
                [ text model.property_search ]
            ; select
                [ onChange selectProperty; Tea.Html2.Attributes.size 5 ]
                ( Belt.Array.map model.property_suggestions property_option
                |> Belt.List.fromArray )
            ]
        ; div
            [ id "object-fields" ]
            [ label [ for' "object-search-field" ] [ text "Object" ]
            ; input'
                [ type' "text"
                ; id "object-search-field"
                ; onInput saveObjSearch
                ]
                [ text model.obj_search ]
            ; select
                [ onChange selectObj; Tea.Html2.Attributes.size 5 ]
                ( Belt.Array.map model.obj_suggestions obj_option
                |> Belt.List.fromArray )
            ]
        ; button [ type' "button"; onClick addStatement ] [ text "Add" ]
        ]
    ; button [ type' "submit" ] [ text "Create group" ]
    ]


let view model =
  let open Tea.Html in
  div ~unique:"create_group" [ id "create-group" ] [ statement_form_view model ]
