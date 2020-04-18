type property = string
type obj = string

type statement = obj Js.Dict.t

module StmCmp =
  Belt.Id.MakeComparable
  (struct
    type t = property
    let cmp a b = String.compare a b
  end)

type model =
  {
    matrix_client : Matrix.client ref;
    (* statements : (property * obj) array; *)
    (* statements : (obj array) Belt.Map.String.t; *)
    statements : (StmCmp.t, (obj array), StmCmp.identity) Belt.Map.t;
    property_search : string;
    property_suggestions : property array;
    property_selected : string;
    obj_search : string;
    obj_suggestions : obj array;
    obj_selected : string;
  }

let init matrix_client =
  {
      matrix_client;
      statements = Belt.Map.make ~id:(module StmCmp);
      property_search = "img:location";
      property_suggestions = [|"img:location"; "img:subgroup"; "img:about"|];
      property_selected = "";
      obj_search = "";
      obj_suggestions = [||];
      obj_selected = "";
  }

type msg =
  | GoTo of Router.route
  | SavePropertySearch of string
  | SelectProperty of string
  | SaveObjSearch of string
  | SelectObj of string
  | ReceivedObjResults of ((string * string array), string Tea.Http.error) Tea.Result.t
  | AddStatement
  | RemoveObj of string * string
  [@@bs.deriving {accessors}]
  (* TODO: rename module so its used for create and edit *)
  (* TODO: add create/edit room *)

let obj_search_cmd property obj =
  let open Tea.Http in
  let url =
    "http://api.imago.local:4000/obj/search"
    ^ "?property=" ^ property
    ^ "&term=" ^ obj
  in
    let decode_response = 
      let open Tea.Json.Decoder in
      (* decodeString (list string) json *)
      (* map (fun ) *)
      map2 (fun a b -> (a, b))
      (field "term" string)
      (field "results" (array string))
      |> decodeValue
  in
  let handle_response response =
    let { status; body; _ } = response in
    if status.code <> 200
    then (Tea_result.Error status.message)
    else (
      match body with
      | JsonResponse json -> (decode_response json)
      | _ -> assert false)
  in
  request
    { method' = "GET"
    ; headers = []
    ; url = url
    ; body = Web.XMLHttpRequest.EmptyBody
    ; expect = Expect (JsonResponseType, handle_response)
    ; timeout = None
    ; withCredentials = false
    }
  |> send receivedObjResults
  (* TODO: fetch with IRI,
   * use it so property/obj are (IRI * "name (description)") *)
  (* TODO: debounce, maybe cache *)
  (* |> toTask *)

let update model = function
  | GoTo _ ->
      model, Tea.Cmd.none
  | SavePropertySearch property ->
      {model with property_search = property},
      Tea.Cmd.none
  | SelectProperty property ->
      {model with property_selected = property},
      Tea.Cmd.none
  | SaveObjSearch obj ->
      {model with obj_search = obj},
      obj_search_cmd model.property_selected obj
  | SelectObj obj ->
      {model with obj_selected = obj},
      Tea.Cmd.none
  | ReceivedObjResults(Error err) ->
      Js.log err;
      model, Tea.Cmd.none
  | ReceivedObjResults(Ok (term, results)) ->
      let model = if term == model.obj_search then
        {model with obj_suggestions = results}
      else
        model
      in
      model,
      Tea.Cmd.none
  | AddStatement ->
      let new_statements = 
        Belt.Map.update model.statements model.property_selected
        (function
          | None -> Some (Belt.Array.make 1 model.obj_selected)
          | Some objs -> Some (Belt.Array.concat objs [|model.obj_selected|])
        )
      in (* TODO: empty selected_pty/obj after add *)
        {model with statements = new_statements},
        Tea.Cmd.none
  | RemoveObj (property, obj) ->
      let new_statements = 
        Belt.Map.update model.statements property
        (function
          | None -> None
          | Some objs -> Some (Belt.Array.keep objs (fun x -> x <> obj))
        )
      in
        {model with statements = new_statements},
        Tea.Cmd.none


let statement_list_view model =
  let open Tea.Html in
  let obj_view property obj =
    div []
    [
      div [] [text obj];
      button [onClick (removeObj property obj)] [text "X"]
    ]
  in
  let statement_view (property, objs) =
    div []
    [
      div [] [text property];
      div [] (Belt.Array.map objs (obj_view property) |> Belt.List.fromArray)
    ]
    (* text (property ^ ": " ^ obj) *)
  in
  div []
    (Belt.Map.toList model.statements
    |. Belt.List.map statement_view)
    (* (Belt.Array.map model.statements statement_view *)
    (* |> Belt.List.fromArray) *)

let statement_form_view model =
  let open Tea.Html in
  let property_option property =
    option' [] [text property]
  in (* TODO: add selected for what is really selected *)
  let obj_option obj =
    option' [] [text obj]
  in (* TODO: add selected for what is really selected *)
  div []
  [
    input'
      [type' "text";
       onInput savePropertySearch]
      [text model.property_search];
    select
      [onChange selectProperty;
       Tea.Html2.Attributes.size 5]
      (Belt.Array.map model.property_suggestions property_option
      |> Belt.List.fromArray);
    input'
      [type' "text";
       onInput saveObjSearch]
      [text model.obj_search];
    select
      [onChange selectObj;
       Tea.Html2.Attributes.size 5]
      (Belt.Array.map model.obj_suggestions obj_option
      |> Belt.List.fromArray);
    button
      [onClick addStatement]
      [text "Add"]
  ]

let view model =
  let open Tea.Html in
  div []
  [
    statement_list_view model;
    statement_form_view model;
  ]
