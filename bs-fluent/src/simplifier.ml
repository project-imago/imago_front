open Ast

type simplified_pattern = simplified_pattern_element array

and simplified_pattern_element =
  | TextElement of string
  | Expression of simplified_expression

and simplified_expression =
  | Literal of literal
  | Select of simplified_expression * simplified_variant array
  | VariableRef of string
  | FunctionRef of string * simplified_param array
  | BuiltInRef of string * simplified_expression * simplified_param array

and literal =
  | LiteralString of string
  | LiteralInt of string
  | LiteralFloat of string

and simplified_variant = string * simplified_pattern * bool

and simplified_param = string * string

type fn =
  { name : string
  ; bodies : (string * simplified_pattern) array
  ; params : string Belt.Map.String.t
  ; public : bool
  }

let make_fn_name namespace name public =
  let name =
    match (namespace, name) with "", _ | _, "" -> name | _, _ -> "_" ^ name
  in
  let namespace =
    match public with true -> namespace | false -> "_" ^ namespace
  in
  let formatted_namespace =
    Js.String.replace [%bs.raw {|/-/g|}] "_" namespace
  in
  let formatted_name = Js.String.replace [%bs.raw {|/-/g|}] "_" name in
  formatted_namespace ^ formatted_name


let simplify_identifier = function
  | NumberLiteral { value } ->
      value
  | Identifier { name } ->
      name


let simplify_literal = function
  | NumberLiteral { value } ->
      value
  | StringLiteral { value } ->
      "\"" ^ value ^ "\""


let get_named_argument = function CallArguments { named } -> named

let simplify_named_arguments args =
  Belt.Array.map args (function NamedArgument { name; value } ->
      (simplify_identifier name, simplify_literal value))


let rec simplify_expression node params ?(in_builtin = false) =
  match node with
  | StringLiteral { value } ->
      Literal (LiteralString value)
  | NumberLiteral { value } ->
      Literal (LiteralInt value)
  | MessageReference { id; attribute } ->
      let namespace = simplify_identifier id in
      let name =
        match Js.Nullable.toOption attribute with
        | Some s ->
            simplify_identifier s
        | None ->
            ""
      in
      let formatted_name = make_fn_name namespace name true in
      FunctionRef (formatted_name, [||])
  | TermReference { id; attribute; arguments } ->
      let namespace = simplify_identifier id in
      let name =
        match Js.Nullable.toOption attribute with
        | Some s ->
            simplify_identifier s
        | None ->
            ""
      in
      let formatted_name = make_fn_name namespace name false in
      let params =
        match Js.Nullable.toOption arguments with
        | Some a ->
            simplify_named_arguments (get_named_argument a)
        | None ->
            [||]
      in
      FunctionRef (formatted_name, params)
  | VariableReference { id } ->
      let name = simplify_identifier id in
      ( match (in_builtin, Belt.Map.String.get params name) with
      | false, Some "int" ->
          BuiltInRef ("NUMBER", VariableRef name, [||])
      | false, Some "Js.Date.t" ->
          BuiltInRef ("DATETIME", VariableRef name, [||])
      | _ ->
          VariableRef name )
  | FunctionReference { id; arguments } ->
      let name = simplify_identifier id in
      let subject, fun_params =
        match arguments with
        | CallArguments { positional; named } ->
            (Belt.Array.getExn positional 0, simplify_named_arguments named)
        (* simplify_params named) *)
      in
      BuiltInRef
        (name, simplify_expression subject params ~in_builtin:true, fun_params)
  | SelectExpression { selector; variants } ->
      let pattern_array_with_default =
        Belt.Array.map variants (function Variant { key; value; default } ->
            (* Js.log key; *)
            let elements =
              match value with Pattern { elements } -> elements
            in
            (simplify_identifier key, simplify_pattern elements params, default))
      in
      Select
        ( simplify_expression selector params ~in_builtin
        , pattern_array_with_default )


(* Literal (LiteralString "FIXME") *)

(* and simplify_variant_key = function *)
(*   | Variant *)
and simplify_pattern (element_array : node array) params =
  element_array
  |. Belt.Array.map (function
         | TextElement { value } ->
             TextElement value
         | Placeable { expression } ->
             Expression
               (simplify_expression expression params ~in_builtin:false))


let merge_params _key maybe_a maybe_b =
  match (maybe_a, maybe_b) with
  | Some "Js.Date.t", _ | _, Some "Js.Date.t" ->
      Some "Js.Date.t"
  | Some "float", _ | _, Some "float" ->
      Some "float"
  | Some "int", _ | _, Some "int" ->
      Some "int"
  | Some _, _ | _, Some _ ->
      Some "string"
  | None, None ->
      None


let get_first_argument = function
  | CallArguments { positional } ->
      Belt.Array.getExn positional 0


let rec reduce_pattern_for_params curr_type_and_acc pattern_element =
  (* Js.log pattern_element; *)
  (* Js.log curr_type_and_acc; *)
  let curr_type, curr_acc = curr_type_and_acc in
  match pattern_element with
  | Pattern { elements } ->
      (* Js.log "pattern"; *)
      let _, acc =
        Belt.Array.reduce elements curr_type_and_acc reduce_pattern_for_params
      in
      (curr_type, Belt.Map.String.merge acc curr_acc merge_params)
  | VariableReference { id } ->
      (* Js.log "variable"; *)
      (* Js.log ("adding " ^ (simplify_identifier id) ^ " as " ^ curr_type); *)
      ( curr_type
      , Belt.Map.String.set curr_acc (simplify_identifier id) curr_type )
  | FunctionReference { id; arguments } ->
      (* Js.log "function"; *)
      (* Js.log ("function ref with " ^ (simplify_identifier id)); *)
      let param_type = match (simplify_identifier id) with
      | "NUMBER" -> "int"
      | "DATETIME" -> "Js.Date.t"
      in
      let _, acc =
        reduce_pattern_for_params
          (param_type, curr_acc)
          (get_first_argument arguments)
      in
      (* Js.log acc; *)
      (curr_type, Belt.Map.String.merge acc curr_acc merge_params)
  | SelectExpression { selector; variants } ->
      (* Js.log "select"; *)
      let _, params_selector =
        reduce_pattern_for_params curr_type_and_acc selector
      in
      (* Js.log params_selector; *)
      let _, params_variants =
        Belt.Array.reduce variants curr_type_and_acc reduce_pattern_for_params
      in
      (* Js.log params_variants; *)
      ( curr_type
      , Belt.Map.String.merge params_selector params_variants merge_params )
  | Variant { value } ->
      (* Js.log "variant"; *)
      let _, acc = reduce_pattern_for_params curr_type_and_acc value in
      (curr_type, Belt.Map.String.merge acc curr_acc merge_params)
  | Placeable { expression } ->
      (* Js.log "placeable"; *)
      let _, acc = reduce_pattern_for_params curr_type_and_acc expression in
      (* Js.log acc; *)
      (curr_type, Belt.Map.String.merge acc curr_acc merge_params)
  | _ ->
      (curr_type, curr_acc)


let get_pattern_params pattern_elements =
  let _, acc =
    Belt.Array.reduce
      pattern_elements
      ("string", Belt.Map.String.empty)
      reduce_pattern_for_params
  in
  acc


let make_fn ({ id; value } : entry) public namespace lc =
  let name = make_fn_name namespace (simplify_identifier id) public in
  let pattern_elements =
    match Js.Nullable.toOption value with
    | None ->
        [||]
    | Some node ->
      (match node with Pattern { elements } -> elements)
  in
  let params = get_pattern_params pattern_elements in
  let simplified_pattern = simplify_pattern pattern_elements params in
  { name
  ; bodies = [| ("\"" ^ lc ^ "\"", simplified_pattern) |]
  ; params
  ; public = true
  }


let make_entry (entry : entry) public lc =
  let main_function =
    match Js.Nullable.toOption entry.value with
    | None ->
        []
    | Some _ ->
        [ make_fn entry public "" lc ]
  in
  let name = simplify_identifier entry.id in
  Belt.List.concat
    main_function
    ( entry.attributes
    |. Belt.List.fromArray
    |. Belt.List.map (function Attribute attribute ->
           make_fn attribute public name lc) )


let simplify_ast lc node : fn array =
  match node with
  | Resource { body } ->
      body
      |. Belt.Array.keep (function
             | Message _ ->
                 true
             | Term _ ->
                 true
             | _ ->
                 false)
      |. Belt.Array.map (function
             | Message entry ->
                 make_entry entry true lc
             | Term entry ->
                 make_entry entry false lc)
      |. Belt.List.fromArray
      |. Belt.List.flatten
      |. Belt.List.toArray
