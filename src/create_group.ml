type search_result = <iri : string ; label : string ; description : string> Js.t

let to_text obj =
  obj##label
  ^ " ("
  ^ obj##description
  ^ ")"

type add_statement_step =
  | Start
  | PropertySelection
  | ObjectSelection

type model =
  { matrix_client : Matrix.client ref
  ; name : string
  ; topic : string
  ; (* statements : (property * obj) array; *)
    (* statements : (obj array) Belt.Map.String.t; *)
    statements : Labeled_statements.t
  ; property_selected : Labeled_statements.labeled_object option
  ; obj_search : string
  ; obj_suggestions : search_result array
  ; obj_selected : search_result option
  ; add_statement_step : add_statement_step
  }

let init matrix_client =
  { matrix_client
  ; name = ""
  ; topic = ""
  ; statements = Labeled_statements.empty
  ; property_selected = None
  ; obj_search = ""
  ; obj_suggestions = [||]
  ; obj_selected = None
  ; add_statement_step = Start
  }


type msg =
  | GoTo of Router.route
  | SaveName of string
  | SaveTopic of string
  | ShowStartStep
  | ShowPropertyStep
  (* | AddStatementNextStep *)
  (* | AddStatementPrevStep *)
  | SelectProperty of Labeled_statements.labeled_object
  | SaveObjSearch of string
  | SelectObj of string
  | ReceivedObjResults of
      (string * search_result array, string Tea.Http.error) Tea.Result.t
  | AddStatement
  | RemoveObj of search_result * search_result
  | CreateGroup
  | CreatedGroup of (Matrix.create_room_response, string) Tea.Result.t
  | SentGroupEvents of (string array, string) Tea.Result.t
[@@bs.deriving { accessors }]

(* TODO: rename module so its used for create and edit *)
(* TODO: add create/edit room *)

let obj_search_cmd property obj =
  let property_name = match (Custom_properties.variant_of_iri property##iri) with
  | Location -> "location"
  | Subgroup -> "subgroup"
  | About -> "about" in
  let open Tea.Http in
  let url =
    Config.api_url
    ^ "/api/obj/search"
    ^ "?property="
    ^ property_name
    ^ "&term="
    ^ obj
    ^ "&lc="
    ^ !Locale.get
  in
  Js.log url;
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
                 ([%bs.obj { iri = a; label = b; description = c }] :
                   search_result))
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
  [|
    (* Statements.StatementsState.send *)
    (*    !(model.matrix_client) *)
    (*    room_id *)
    (*    "pm.imago.group.statements" *)
    (*    [%bs.obj { statements = Statements.to_state model.statements }] *)
    (*    "" *)
        Matrix.TypeState.send
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
  | ShowStartStep ->
      ({ model with add_statement_step = Start }, Tea.Cmd.none)
  | ShowPropertyStep ->
      ({ model with add_statement_step = PropertySelection }, Tea.Cmd.none)
  (* | AddStatementNextStep -> *)
  (*     let model = match model.add_statement_step with *)
  (*     | Start -> {model with add_statement_step = PropertySelection} *)
  (*     | PropertySelection -> {model with add_statement_step = ObjectSelection} *)
  (*     | ObjectSelection -> {model with add_statement_step = Start} *)
  (*     in *)
  (*     (model, Tea.Cmd.none) *)
  (* | AddStatementPrevStep -> *)
  (*     let model = match model.add_statement_step with *)
  (*     | Start -> {model with add_statement_step = Start} *)
  (*     | PropertySelection -> {model with add_statement_step = Start} *)
  (*     | ObjectSelection -> {model with add_statement_step = PropertySelection} *)
  (*     in *)
  (*     (model, Tea.Cmd.none) *)
  | SelectProperty property_item ->
      (* let property = *)
      (*   Belt.Array.getBy model.property_suggestions (fun x -> x##label == property_item) *)
      (* in *)
      Js.log property_item;
      ({ model with property_selected = Some property_item;
                    add_statement_step = ObjectSelection
       }, Tea.Cmd.none)
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
        Belt.Array.getBy model.obj_suggestions (fun x -> x##iri == obj_item)
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
      let new_statements =
        match (model.property_selected, model.obj_selected) with
        | Some property, Some obj ->
            Labeled_statements.add_statements model.statements property obj
        | _ ->
            model.statements
      in
      ( { model with
          statements =
            new_statements;
          add_statement_step = Start;
          obj_suggestions = [||]
            (* property_selected = None; *)
            (* obj_selected = None; *)
        }
      , Tea.Cmd.none )
  | RemoveObj (property, obj) ->
      let new_statements =
        Labeled_statements.remove_obj model.statements property obj
      in
      ({ model with statements = new_statements }, Tea.Cmd.none)
  | CreateGroup ->
      (model, create_group_cmd model)
  | CreatedGroup (Tea.Result.Ok res) ->
      ( model
      , (* TODO: add room_id in state to use for edit group *)
        Tea.Cmd.batch
          [ send_group_events_cmd model res##room_id
          ; Tea.Cmd.msg (goTo (Group (Id res##room_id)))
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
  let obj_view property (obj : Labeled_statements.labeled_object) =
    div
      [ id "object-item" ]
      [ span [] [ text (Labeled_statements.obj_to_text obj) ]
      ; button
          [ type' "button"
          ; onClick (removeObj property obj)
          ; class' "icon"
          ; Icons.aria_label "Remove statement"
          ]
          [ Icons.icon "trash" ]
      ]
  in
  let statement_view (property, objs) =
    div
      [ id "statement-item" ]
      [ div [ id "property-item" ] [ text (Labeled_statements.obj_to_text property) ]
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
let add_statement_start_view model =
  let open Tea.Html in
  div []
    [ button [ type' "button"; onClick showPropertyStep ] [ text "Add a new
    link" ]
    ]

let add_statement_property_view model =
  let open Tea.Html in
  let property_button property =
    button [onClick (selectProperty property)]
    [text (Labeled_statements.obj_to_text property)]
  in
  div [] 
    [ div [id "property-buttons"]
        (Custom_properties.localized_properties !Locale.get
        |> Tablecloth.Array.map ~f:property_button
        |> Tablecloth.Array.to_list
        )
    ; div [id "property-step-control"]
      [ button [ type' "button"; onClick showStartStep ] [ text "Cancel" ]
      ]
    ]

let add_statement_object_view model =
  let open Tea.Html in
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
  let obj_option (obj) =
    option'
      [ value obj##iri; Attributes.selected (is_obj_selected model obj) ]
      [ text (obj##label ^ " (" ^ obj##description ^ ")") ]
  in
  div []
      [ div
          [ id "object-fields" ]
          [ label [ for' "object-search-field" ] [ text "Search" ]
          ; label [ class' "icon-label" ]
              [ Icons.icon "search"
              ; input'
                  [ type' "text"
                  ; id "object-search-field"
                  ; onInput saveObjSearch
                  ]
                  [ text model.obj_search ]
              ]
          ; select
              [ onChange selectObj; Tea.Html2.Attributes.size 5 ]
              ( Belt.Array.map model.obj_suggestions obj_option
              |> Belt.List.fromArray )
          ]
      ; div [id "object-step-control"]
        [ button [ type' "button"; onClick showPropertyStep ] [ text "Back" ]
        ; button [ type' "button"; onClick addStatement; class' "default" ] [ text "Add" ]
        ]
      ]

let new_statement_form_view model =
  match model.add_statement_step with
  | Start -> add_statement_start_view model
  | PropertySelection -> add_statement_property_view model
  | ObjectSelection -> add_statement_object_view model

let form_view model =
  let open Tea.Html in
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
    ; div [id "statements"]
      [ label [] [ text "Links" ]
      ; statement_list_view model
      ; new_statement_form_view model
      ]
    ; button [ type' "submit" ] [ text "Create group" ]
    ]


let view model =
  let open Tea.Html in
  div ~unique:"create_group" [ id "create-group" ] [ form_view model ]
