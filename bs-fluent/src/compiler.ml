open Simplifier

let string_of_literal = function
  | LiteralString str ->
      "\"" ^ str ^ "\""
  | LiteralInt i ->
      i
  | LiteralFloat f ->
      f


let builtin_name name =
  match name with
  | "NUMBER" ->
      "Fluent.number_format"
  | "DATETIME" ->
      "Fluent.datetime_format"
  | other ->
      other


let build_param (param_type, param_name) = param_type ^ " = " ^ param_name

let build_builtin_param (param_type, param_name) =
  "~" ^ param_type ^ ":" ^ param_name


let build_params params =
  match Js.Array.length params with
  | 0 ->
      ""
  | _ ->
      let formatted_params =
        Belt.Array.map params build_param |> Js.Array.joinWith "; "
      in
      " { " ^ formatted_params ^ " }"


let build_builtin_params name params =
  let params_maker =
    match name with
    | "NUMBER" ->
        "Fluent.Runtime.make_number_params"
    | "DATETIME" ->
        "Fluent.Runtime.make_datetime_params"
    | other ->
        other
  in
  let formatted_params =
    match Js.Array.length params with
    | 0 ->
        ""
    | _ ->
        Belt.Array.map params build_builtin_param |> Js.Array.joinWith " "
  in
  "(" ^ params_maker ^ " " ^ formatted_params ^ "())"


let extract_type_param = function
  | BuiltInRef (name, subject, params) ->
    ( match name with
    | "NUMBER" ->
        let type_expr, new_params =
          Belt.Array.reduce
            params
            ("", [||])
            (fun (type_expr, new_params) (name, value) ->
              match name with
              | "type" ->
                  (" ~_type:" ^ value, new_params)
              | _ ->
                  Js.Array.push (name, value) new_params ;
                  ("", new_params))
        in
        (type_expr, BuiltInRef (name, subject, new_params))
    | _ ->
        ("", BuiltInRef (name, subject, params)) )
  | other ->
      ("", other)


let build_locale_getter locale_getter =
  match Js.Nullable.toOption locale_getter with Some s -> s | None -> "lc"


let build_locale_argument locale_getter =
  match Js.Nullable.toOption locale_getter with Some _ -> "" | None -> "lc"


let remove_builtin = function
  | BuiltInRef (_name, subject, _params) ->
      subject
  | other ->
      other


let rec build_expression locale_getter = function
  | Literal l ->
      string_of_literal l
  | VariableRef ref ->
      "params." ^ ref
  | FunctionRef (name, params) ->
      "("
      ^ name
      ^ build_params params
      ^ " "
      ^ build_locale_argument locale_getter
      ^ ")"
  | Select (selector, pattern_array) ->
      build_select locale_getter selector pattern_array
  | BuiltInRef (name, subject, params) ->
      "("
      ^ builtin_name name
      ^ " "
      ^ build_expression locale_getter subject
      ^ " "
      ^ build_builtin_params name params
      ^ " "
      ^ build_locale_getter locale_getter
      ^ ")"


and build_pattern_element locale_getter = function
  | TextElement text ->
      "{js|" ^ text ^ "|js}"
  | Expression expr ->
      build_expression locale_getter expr


and build_select locale_getter selector pattern_array_with_default =
  match selector with
  | BuiltInRef ("NUMBER", subject, params) ->
      build_select_number locale_getter selector pattern_array_with_default
  | _ ->
      build_select_other locale_getter selector pattern_array_with_default


and build_select_number locale_getter selector pattern_array_with_default =
  let type_param, selector = extract_type_param selector in
  let selector_without_builtin = remove_builtin selector in
  let built_selector = build_expression locale_getter selector in
  let selector =
    "("
    ^ built_selector
    ^ ", Fluent.plural_rule "
    ^ build_expression locale_getter selector_without_builtin
    ^ " lc"
    ^ type_param
    ^ ")"
  in
  let patterns =
    Belt.Array.keep pattern_array_with_default (function
        | _name, _pattern, default -> not default)
    |. Belt.Array.map (function name, pattern, _ ->
           ("\"" ^ name ^ "\", _ | _, \"" ^ name ^ "\"", pattern))
  in
  let default_pattern =
    Belt.Array.keep pattern_array_with_default (function
        | _name, _pattern, default -> default)
    |. Belt.Array.get 0
    |. Belt.Option.map (function _name, pattern, _ -> ("_, _", pattern))
  in
  build_switch locale_getter selector patterns default_pattern


and build_select_other locale_getter selector pattern_array_with_default =
  let selector = build_expression locale_getter selector in
  let patterns =
    Belt.Array.keep pattern_array_with_default (function
        | _name, _pattern, default -> not default)
    |. Belt.Array.map (function name, pattern, _ ->
           ("\"" ^ name ^ "\"", pattern))
  in
  let default_pattern =
    Belt.Array.keep pattern_array_with_default (function
        | _name, _pattern, default -> default)
    |. Belt.Array.get 0
    |. Belt.Option.map (function _name, pattern, _ -> ("_", pattern))
  in
  build_switch locale_getter selector patterns default_pattern


and build_pattern locale_getter pattern =
  Belt.Array.map pattern (build_pattern_element locale_getter)
  |> Js.Array.joinWith " ^ "


and build_switch_case locale_getter (name, pattern) =
  "| " ^ name ^ " ->\n" ^ build_pattern locale_getter pattern


and build_switch locale_getter selector pattern_array default_pattern =
  "(match "
  ^ selector
  ^ " with\n"
  ^ ( Belt.Array.map pattern_array (build_switch_case locale_getter)
    |> Js.Array.joinWith "\n" )
  ^ ( match default_pattern with
    | None ->
        ""
    | Some pattern ->
        "\n" ^ build_switch_case locale_getter pattern )
  ^ ")\n"


(* | Select of simplified_expression * simplified_variant array *)
(* | BuiltInRef of string * simplified_expression * simplified_param array *)

let type_params { name; params } =
  let inside_record =
    Belt.Map.String.toArray params
    |. Belt.Array.map (fun (k, v) -> k ^ " : " ^ v)
    |> Js.Array.joinWith " ; "
  in
  "type " ^ name ^ "_params = { " ^ inside_record ^ " }\n"


let function_has_params fn = not (Belt.Map.String.isEmpty fn.params)

let build_function_head fn locale_getter =
  let params =
    if function_has_params fn then " (params : " ^ fn.name ^ "_params)" else ""
  in
  let locale_argument = build_locale_argument locale_getter in
  let added_unit =
    match (params, locale_argument) with "", "" -> "()" | _ -> ""
  in
  "let " ^ fn.name ^ params ^ " " ^ locale_argument ^ added_unit ^ " =\n"


let build_function default_lc locale_getter fn =
  let type_params = if function_has_params fn then type_params fn else "" in
  let head = build_function_head fn locale_getter in
  let body =
    match Js.Array.length fn.bodies with
    | 0 ->
        ""
    | 1 ->
        build_pattern locale_getter (snd (Belt.Array.getExn fn.bodies 0))
    | _ ->
        let patterns =
          Belt.Array.keep fn.bodies (function lc, _pattern ->
              (* Js.log lc; Js.log default_lc; *)
              not (lc = default_lc))
        in
        let default_pattern =
          Belt.Array.keep fn.bodies (function lc, _pattern -> lc = default_lc)
          |. Belt.Array.get 0
          |. Belt.Option.map (function _lc, pattern -> ("_", pattern))
        in
        build_switch
          locale_getter
          (build_locale_getter locale_getter)
          (*[||]*) patterns
          default_pattern
  in
  type_params ^ head ^ body


let build fn_array default_lc locale_getter =
  fn_array
  |. Belt.Map.String.valuesToArray
  |. Belt.Array.map (build_function ("\"" ^ default_lc ^ "\"") locale_getter)
  |> Js.Array.joinWith "\n\n"


let precompile resource lc =
  (* let () = Js.log resource in *)
  let ast = Parser.build_ast resource in
  (* let () = Js.log ast in *)
  let fn_array = Simplifier.simplify_ast lc ast in
  (* let () = Js.log output in *)
  fn_array


let reduce_fn_arrays acc fn_array =
  Belt.Array.reduce fn_array acc (fun acc2 fn_array ->
      Belt.Map.String.update acc2 fn_array.name (function
          | None ->
              Some fn_array
          | Some f ->
              Some
                { f with bodies = Belt.Array.concat f.bodies fn_array.bodies }))


let compile fn_array_array default_lc locale_getter =
  let merged_array =
    Belt.Array.reduce fn_array_array Belt.Map.String.empty reduce_fn_arrays
  in
  let output = build merged_array default_lc locale_getter in
  (* let () = Js.log output in *)
  output
