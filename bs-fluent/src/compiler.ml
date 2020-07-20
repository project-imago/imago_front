open Ast

type build_ast = js_node -> node [@bs]
let rec build_ast node : node =
  (* Js.log (Js.Json.stringify [%bs.raw {|node|}]); *)
  Js.log node._type;
  (match node._type with
  (* | "BaseNode" -> *)
  (*     BaseNode *)
  (* | "SyntaxNode" -> *)
  (*     SyntaxNode *)
  (* | "Entry" -> *)
  (*     Entry *)
  (* | "PatternElement" -> *)
  (*     PatternElement *)
  (* | "Expression" -> *)
  (*     Expression *)
  (* | "Literal" -> *)
  (*     Literal *)
  (* | "BaseComment" -> *)
  (*     BaseComment *)
  | "Resource" ->
      Resource {body = (Belt.Array.map node.body build_ast)}
  | "Message" ->
      Message
      { id = (build_ast node.id)
      ; value = (bind_null node.value)
        (*(Js.Nullable.bind
          node.value (*[%bs.raw{|node.value|}] *)
          (fun x -> build_ast x)) (* build_ast *) *)
      ; attributes = (bind_array node.attributes)
      ; comment = (bind_null node.comment)
      }
  | "Term" ->
      Term
      { id = (build_ast node.id)
      ; value = (bind_null node.value)
      ; attributes = (bind_array node.attributes)
      ; comment = (bind_null node.comment)
      }
  | "Pattern" ->
      Pattern
      { elements = bind_array node.elements}
  | "TextElement" ->
      TextElement
      { value = [%bs.raw{|node.value|}] }
  | "Placeable" ->
      Placeable
      { expression = build_ast node.expression }
  | "StringLiteral" ->
      StringLiteral
      { value = [%bs.raw{|node.value|}] }
  | "NumberLiteral" ->
      NumberLiteral
      { value = [%bs.raw{|node.value|}] }
  | "MessageReference" ->
      MessageReference
      { id = build_ast node.id
      ; attribute = bind_null node.attribute
      }
  | "TermReference" ->
      TermReference
      { id = build_ast node.id
      ; attribute = bind_null node.attribute
      ; arguments = bind_null node.arguments
      }
  | "VariableReference" ->
      VariableReference
      { id = build_ast node.id }
  | "FunctionReference" ->
      FunctionReference
      { id = build_ast node.id
      ; arguments = build_ast [%bs.raw{|node.arguments|}]
      }
  | "SelectExpression" ->
      SelectExpression
      { selector = build_ast node.selector
      ; variants = bind_array node.variants
      }
  | "CallArguments" ->
      CallArguments
      { positional = bind_array node.positional
      ; named = bind_array node.named
      }
  | "Attribute" ->
      Attribute
      { id = build_ast node.id
      ; value = bind_null [%bs.raw{|node.value|}]
      ; attributes = [||]
      ; comment = Js.Nullable.null

      }
  | "Variant" ->
      Variant
      { key = build_ast node.key
      ; value = build_ast [%bs.raw{|node.value|}]
      ; default = node.default
      }
  | "NamedArgument" ->
      NamedArgument
      { name = build_ast node.name
      ; value = build_ast [%bs.raw{|node.value|}]
      }
  | "Identifier" ->
      Identifier
      { name = [%bs.raw{|node.name|}] }
  | "Comment" ->
      Comment
      { content = node.content }
  | "GroupComment" ->
      GroupComment
      { content = node.content }
  | "ResourceComment" ->
      ResourceComment
      { content = node.content }
  | "Junk" ->
      Junk
      { annotations = bind_array node.annotations
      ; content = node.content}
  | "Span" ->
      Span
      { start = node.start
      ; _end = node._end
      }
  | "Annotation" ->
      Annotation
      { code = node.code
      ; arguments = [%bs.raw{|node.arguments|}]
      ; message = node.message
      }
  | _ ->
      Junk {annotations = [||]; content = ""})

  and bind_null nullable =
  (* Js.Nullable.bind nullable build_ast *)
    match Js.Nullable.toOption nullable with
    | None -> (Obj.magic (nullable: 'a Js.Nullable.t): 'b Js.Nullable.t)
    | Some x -> Js.Nullable.return (build_ast x)

  and bind_array arr =
    Belt.Array.map arr build_ast

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
and simplified_variant = (string * simplified_pattern * bool)
and simplified_param = string * string

type fn =
  { name : string
  ; bodies : (string * simplified_pattern) array
  ; params : string Belt.Map.String.t
  ; public : bool
  }

let string_of_literal = function
  | LiteralString str -> "\"" ^ str ^ "\""
  | LiteralInt i -> i
  | LiteralFloat f -> f

let builtin_name name =
  match name with
  | "NUMBER" -> "Fluent.number_format"
  | "DATETIME" -> "Fluent.datetime_format"
  | other -> other

let build_param (param_type, param_name) =
  param_type ^ " = " ^ param_name

let build_builtin_param (param_type, param_name) =
  "~" ^ param_type ^ ":" ^ param_name

let build_params params =
  match (Js.Array.length params) with
  | 0 -> ""
  | _ ->
      let formatted_params =
        Belt.Array.map params build_param
        |> Js.Array.joinWith "; "
      in
      " { " ^ formatted_params ^ " }"


let build_builtin_params name params =
  let params_maker = match name with
  | "NUMBER" -> "Fluent.Runtime.make_number_params"
  | "DATETIME" -> "Fluent.Runtime.make_datetime_params"
  | other -> other
  in
  let formatted_params =
    match (Js.Array.length params) with
    | 0 -> ""
    | _ ->
        Belt.Array.map params build_builtin_param
        |> Js.Array.joinWith " "
  in
  "(" ^ params_maker ^ " "^ formatted_params ^ "())"

let extract_type_param = function
  | BuiltInRef (name, subject, params) ->
      (match name with
      | "NUMBER" ->
          let type_expr, new_params = Belt.Array.reduce params ("", [||])
          (fun (type_expr, new_params) (name, value) ->
            match name with
            | "type" -> " ~_type:" ^ value, new_params
            | _ ->
                Js.Array.push (name, value) new_params;
                "", new_params
          ) in
          type_expr, BuiltInRef (name, subject, new_params)
      | _ -> "", BuiltInRef (name, subject, params))
  | other -> "", other

let remove_builtin = function
  | BuiltInRef (_name, subject, _params) -> subject
  | other -> other

let rec build_expression = function
  | Literal l -> string_of_literal l
  | VariableRef ref -> "params." ^ ref
  | FunctionRef (name, params) ->
      "(" ^ name ^ (build_params params) ^ " lc)"
  | Select (selector, pattern_array) -> build_select selector pattern_array
  | BuiltInRef (name, subject, params) ->
      "(" ^ (builtin_name name) ^ " " ^ (build_expression subject) ^ " " ^
      (build_builtin_params name params) ^ " lc)"

    and build_pattern_element = (function
  | TextElement text -> "{js|" ^ text ^ "|js}"
  | Expression expr -> build_expression expr)

and build_select selector pattern_array_with_default =
  match selector with
  | BuiltInRef ("NUMBER", subject, params) ->
      build_select_number selector pattern_array_with_default
  | _ ->
      build_select_other selector pattern_array_with_default


and build_select_number selector pattern_array_with_default =
  let type_param, selector = extract_type_param selector
  in
  let selector_without_builtin = remove_builtin selector in
  let built_selector = build_expression selector in
  let selector =
    "(" ^ built_selector
    ^ ", Fluent.plural_rule " ^ build_expression selector_without_builtin ^ " lc"
    ^ type_param ^ ")" in
  let patterns =
    Belt.Array.keep pattern_array_with_default
    (function (_name, _pattern, default) -> not default)
    |. Belt.Array.map
    (function (name, pattern, _) ->
      "\"" ^ name ^ "\", _ | _, \"" ^ name ^ "\"",
      pattern
    )
  in
  let default_pattern =
    Belt.Array.keep pattern_array_with_default
      (function (_name, _pattern, default) -> default)
    |. Belt.Array.get 0
    |. Belt.Option.map
      (function (_name, pattern, _) -> ("_, _", pattern))
  in
  build_switch selector patterns default_pattern

and build_select_other selector pattern_array_with_default =
  let selector = build_expression selector in
  let patterns =
    Belt.Array.keep pattern_array_with_default
    (function (_name, _pattern, default) -> not default)
    |. Belt.Array.map
    (function (name, pattern, _) ->
      "\"" ^ name ^ "\"",
      pattern
    )
  in
  let default_pattern =
    Belt.Array.keep pattern_array_with_default
      (function (_name, _pattern, default) -> default)
    |. Belt.Array.get 0
    |. Belt.Option.map
      (function (_name, pattern, _) -> ("_", pattern))
  in
  build_switch selector patterns default_pattern

and build_pattern pattern =
  Belt.Array.map pattern build_pattern_element
  |> Js.Array.joinWith " ^ "

and build_switch_case (name, pattern) =
  "| " ^ name ^ " ->\n" ^ (build_pattern pattern)


and build_switch selector pattern_array default_pattern =
  "(match " ^ selector ^ " with\n" ^
  (Belt.Array.map pattern_array build_switch_case
  |> Js.Array.joinWith "\n"
  )
  ^ (match default_pattern with
    | None -> ""
    | Some pattern -> "\n" ^ build_switch_case pattern)
  ^ ")\n"

(* | Select of simplified_expression * simplified_variant array *)
(* | BuiltInRef of string * simplified_expression * simplified_param array *)

let type_params { name; params } =
  let inside_record =
    Belt.Map.String.toArray params
    |. Belt.Array.map (fun (k, v) ->
      k ^ " : " ^ v
    )
    
    |> Js.Array.joinWith " ; "
  in
  "type " ^ name ^ "_params = { " ^ inside_record ^ " }\n"

let function_has_params fn =
  not (Belt.Map.String.isEmpty fn.params)

let build_function_head fn =
  let params = if function_has_params fn then
    " (params : " ^ fn.name ^ "_params)" else "" in
  "let " ^ fn.name
  ^ params
  ^ " lc"
  ^ " =\n"

let build_function default_lc fn =
  let type_params =
    if function_has_params fn then type_params fn else "" in
  let head = build_function_head fn in
  let body =
    match (Js.Array.length fn.bodies) with
    | 0 -> ""
    | 1 -> build_pattern (snd (Belt.Array.getExn fn.bodies 0))
    | _ ->
        let patterns =
          Belt.Array.keep fn.bodies
              (function (lc, _pattern) ->
                Js.log lc; Js.log default_lc;
                not (lc = default_lc))
        in
        let default_pattern =
          Belt.Array.keep fn.bodies
              (function (lc, _pattern) -> (lc = default_lc))
          |. Belt.Array.get 0
          |. Belt.Option.map
              (function (_lc, pattern) -> ("_", pattern))
        in
        build_switch "lc" (*[||]*) patterns default_pattern
  in
  type_params ^ head ^ body

let build fn_array default_lc =
  fn_array
    |. Belt.Map.String.valuesToArray
    |. Belt.Array.map (build_function ("\"" ^ default_lc ^ "\""))
    |> Js.Array.joinWith "\n\n"







let make_fn_name namespace name public =
  let name = match (namespace, name) with
  | "", _ | _, "" -> name
  | _, _ -> "_" ^ name in
  let namespace = match public with
  |  true -> namespace
  | false -> "_" ^ namespace
  in
  let formatted_namespace =
    Js.String.replace [%bs.raw {|/-/g|}] "_" namespace in
  let formatted_name =
    Js.String.replace [%bs.raw {|/-/g|}] "_" name in
  formatted_namespace ^ formatted_name

let simplify_identifier = function
  | NumberLiteral {value} -> value
  | Identifier {name} -> name

let simplify_literal = function
  | NumberLiteral { value } -> value
  | StringLiteral { value } -> "\"" ^ value ^ "\""

let get_named_argument = function
  | CallArguments { named } -> named

let simplify_named_arguments args =
  Belt.Array.map args
  (function NamedArgument { name; value } ->
    simplify_identifier name, simplify_literal value
  )

let rec simplify_expression node params ?(in_builtin=false) =
  match node with
 | StringLiteral
     { value } ->
       Literal (LiteralString value)
 | NumberLiteral
     { value } ->
       Literal (LiteralInt value)
 | MessageReference
     { id 
     ; attribute 
     } ->
      let namespace = simplify_identifier id in
      let name =
        (match Js.Nullable.toOption attribute with
        | Some s -> simplify_identifier s
        | None -> "")
      in
      let formatted_name =
        make_fn_name namespace name true in
      FunctionRef (formatted_name, [||])
 | TermReference
     { id 
     ; attribute 
     ; arguments 
     } ->
      let namespace = simplify_identifier id in
      let name =
        (match Js.Nullable.toOption attribute with
        | Some s -> simplify_identifier s
        | None -> "")
      in
      let formatted_name =
        make_fn_name namespace name false in
      let params =
        (match Js.Nullable.toOption arguments with
        | Some a -> simplify_named_arguments (get_named_argument a)
        | None -> [||])
      in
      FunctionRef (formatted_name, params)
 | VariableReference
     { id } ->
      let name = simplify_identifier id in
      (match (in_builtin, Belt.Map.String.get params name) with
      | false, Some "int" -> BuiltInRef ("NUMBER", VariableRef name, [||])
      | false, Some "Js.Date.t" -> BuiltInRef ("DATETIME", VariableRef name, [||])
      | _ ->
        VariableRef name)
 | FunctionReference
     { id 
     ; arguments 
     } ->
      let name = simplify_identifier id in
      let (subject, fun_params) =
        (match arguments with
        | CallArguments {positional; named} ->
            (Belt.Array.getExn positional 0,
             simplify_named_arguments named)
             (* simplify_params named) *)
        )
      in
       BuiltInRef (name, simplify_expression subject params ~in_builtin:true, fun_params)
 | SelectExpression
     { selector 
     ; variants 
     } ->
       let pattern_array_with_default =
         Belt.Array.map variants
         (function Variant {key; value; default} ->
           Js.log key;
           let elements =
             (match value with | Pattern {elements} -> elements)
           in
           (simplify_identifier key, simplify_pattern elements params, default))
       in
       Select (simplify_expression selector params ~in_builtin, pattern_array_with_default)
       (* Literal (LiteralString "FIXME") *)

     (* and simplify_variant_key = function *)
     (*   | Variant *)


and simplify_pattern (element_array : node array) params =
  element_array
  |. Belt.Array.map
    (function
      | TextElement { value } ->
          TextElement value
      | Placeable { expression } ->
          Expression (simplify_expression expression params ~in_builtin:false)
    )

let merge_params _key maybe_a maybe_b =
  match (maybe_a, maybe_b) with
  | (Some "int", _) | (_, Some "int") -> Some "int"
  | (Some "float", _) | (_, Some "float") -> Some "float"
  | (Some _, _) | (_, Some _) -> Some "string"
  | None, None -> None

let get_first_argument = function
  | CallArguments { positional } ->
      Belt.Array.getExn positional 0



let rec reduce_pattern_for_params curr_type_and_acc pattern_element =
  (* Js.log pattern_element; *)
  (* Js.log curr_type_and_acc; *)
  let curr_type, curr_acc = curr_type_and_acc in
  match pattern_element with
  | Pattern { elements } ->
      Js.log "pattern";
      let _, acc = Belt.Array.reduce elements curr_type_and_acc
      reduce_pattern_for_params in
      curr_type, Belt.Map.String.merge acc curr_acc merge_params
  | VariableReference { id } ->
      Js.log "variable";
      Js.log ("adding " ^ (simplify_identifier id) ^ " as " ^ curr_type);
      curr_type, Belt.Map.String.set curr_acc (simplify_identifier id) curr_type
  | FunctionReference { id; arguments } ->
      Js.log "function";
      (* Js.log ("function ref with " ^ (simplify_identifier id)); *)
      let _, acc = reduce_pattern_for_params ("int", curr_acc) (get_first_argument
      arguments) in
      (* Js.log acc; *)
      curr_type, Belt.Map.String.merge acc curr_acc merge_params

  | SelectExpression { selector; variants} ->
      Js.log "select";
      let _, params_selector = reduce_pattern_for_params curr_type_and_acc selector in
      (* Js.log params_selector; *)
      let _, params_variants = 
        Belt.Array.reduce variants curr_type_and_acc reduce_pattern_for_params in
      (* Js.log params_variants; *)
      curr_type, Belt.Map.String.merge params_selector params_variants merge_params
  | Variant { value } ->
      Js.log "variant";
      let _, acc = reduce_pattern_for_params curr_type_and_acc value in
      curr_type, Belt.Map.String.merge acc curr_acc merge_params
  | Placeable { expression } ->
      Js.log "placeable";
      let _, acc = reduce_pattern_for_params curr_type_and_acc expression in
      Js.log acc;
      curr_type, Belt.Map.String.merge acc curr_acc merge_params
  | _ ->
      curr_type, curr_acc

let get_pattern_params pattern_elements =
  let _, acc = Belt.Array.reduce pattern_elements ("string", Belt.Map.String.empty) reduce_pattern_for_params 
  in
  acc

let make_fn ({id; value} : entry) public namespace lc =
  let name =
    make_fn_name namespace (simplify_identifier id) public
  in
  let pattern_elements =
    match (Js.Nullable.toOption value) with
    | None -> [||]
    | Some node ->
        (match node with
        | Pattern {elements} -> elements)
  in
  let params = get_pattern_params pattern_elements in
  let simplified_pattern = simplify_pattern pattern_elements params in
  { name
  ; bodies = [|("\"" ^ lc ^ "\"", simplified_pattern)|]
  ; params = params
  ; public = true
  }

let make_entry (entry : entry) public lc =
  let main_function = 
    match (Js.Nullable.toOption entry.value) with
    | None -> []
    | Some _ ->
    [ make_fn entry public "" lc ]
  in
  let name = simplify_identifier entry.id in
  Belt.List.concat
    main_function
    (entry.attributes
    |. Belt.List.fromArray
    |. Belt.List.map
      (function
        Attribute attribute ->
          make_fn attribute public name lc
        )
      )

let simplify_ast lc node : fn array =
  match node with
  Resource { body } ->
    body
    |. Belt.Array.keep
      (function
        | Message _ -> true
        | Term _ -> true
        | _ -> false
      )
      |. Belt.Array.map
        (function
          | Message entry ->
              make_entry entry true lc
          | Term entry ->
              make_entry entry false lc
      )
      |. Belt.List.fromArray
      |. Belt.List.flatten
      |. Belt.List.toArray




  (* { name *)
  (* ; bodies = [|("en", simplified_pattern)|] *)
  (* ; params = params *)
  (* ; public = true *)
  (* } *)


let precompile resource lc =
  (* let () = Js.log resource in *)
  let ast = build_ast resource in
  (* let () = Js.log ast in *)
  let fn_array = simplify_ast lc ast in
  (* let () = Js.log output in *)
  fn_array

let reduce_fn_arrays acc fn_array =
  Belt.Array.reduce fn_array acc (fun acc2 fn_array ->
    Belt.Map.String.update acc2 fn_array.name (function
      | None -> Some fn_array
      | Some f ->
          Some {f with bodies = Belt.Array.concat f.bodies fn_array.bodies}
    )
  )

let compile fn_array_array default_lc =
  let merged_array = Belt.Array.reduce fn_array_array Belt.Map.String.empty reduce_fn_arrays in
  let output = build merged_array default_lc in
  (* let () = Js.log output in *)
  output
