(* type entry = *)
(*   [ `Message of message *)
(*   | `Term of term *)
(*   ] *)

(* type literals = *)
(*   [ `StringLiteral of literal *)
(*   | `NumberLiteral of literal *)
(*   ] *)

(* and variant_key = *)
(*   [ `Identifier of identifier *)
(*   | `NumberLiteral of literal *)
(*   ] *)

(*
 * arguments 3
 * id 2
 * name 2
 * value 3
 * *)
type js_node =
  { _type : string [@bs.as "type"]
  ; annotations : js_node array
  (* ; arguments : js_node *)
  ; arguments : js_node Js.Nullable.t
  (* ; arguments : string array *)
  ; attribute : js_node Js.Nullable.t
  ; attributes : js_node array
  ; body : js_node array
  ; code : string
  ; comment : js_node Js.Nullable.t
  ; content : string
  ; default : bool
  ; elements : js_node array
  ; _end : int
  ; expression : js_node
  ; id : js_node
  (* ; id : js_node *)
  ; key : js_node
  ; message : string
  ; named : js_node array
  ; name : js_node
  (* ; name : string *)
  ; positional : js_node array
  ; selector : js_node
  ; start : int
  (* ; value : js_node *)
  ; value : js_node Js.Nullable.t
  (* ; value : string *)
  ; variants : js_node array
  }

type node =
  (* | BaseNode *)
  (* | SyntaxNode *)
  (* | Entry of entry *)
  (* | PatternElement of pattern_element *)
  (* | Expression of expression *)
  (* | Literal of literal *)
  (* | BaseComment of comment *)
  | Resource of resource
  | Message of entry
  | Term of entry
  | Pattern of pattern
  | TextElement of text_element
  | Placeable of placeable
  | StringLiteral of literal
  | NumberLiteral of literal
  | MessageReference of message_reference
  | TermReference of term_reference
  | VariableReference of variable_reference
  | FunctionReference of function_reference
  | SelectExpression of select_expression
  | CallArguments of call_arguments
  | Attribute of entry
  | Variant of variant
  | NamedArgument of named_argument
  | Identifier of identifier
  | Comment of comment
  | GroupComment of comment
  | ResourceComment of comment
  | Junk of junk
  | Span of span
  | Annotation of annotation

and resource = { body : node array }

and entry =
  { id : node
  ; value : node Js.Nullable.t
  ; attributes : node array
  ; comment : node Js.Nullable.t
  }

and pattern = { elements : node array }

and text_element = { value : string }

and placeable = { expression : node }

and literal = { value : string }

and message_reference =
  { id : node
  ; attribute : node Js.Nullable.t
  }

and term_reference =
  { id : node
  ; attribute : node Js.Nullable.t
  ; arguments : node Js.Nullable.t
  }

and variable_reference = { id : node }

and function_reference =
  { id : node
  ; arguments : node
  }

and select_expression =
  { selector : node
  ; variants : node array
  }

and call_arguments =
  { positional : node array
  ; named : node array
  }

(* and attribute = *)
(*   { id : node *)
(*   ; value : node *)
(*   } *)

and variant =
  { key : node
  ; value : node
  ; default : bool
  }

and named_argument =
  { name : node
  ; value : node
  }

and identifier = { name : string }

and comment = { content : string }

and junk =
  { annotations : node array
  ; content : string
  }

and span =
  { start : int
  ; _end : int
  }

and annotation =
  { code : string
  ; arguments : string array
  ; message : string
  }
