open Ast

type build_ast = (js_node -> node[@bs])

let rec build_ast node : node =
  (* Js.log (Js.Json.stringify [%bs.raw {|node|}]); *)
  (* Js.log node._type; *)
  match node._type with
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
      Resource { body = Belt.Array.map node.body build_ast }
  | "Message" ->
      Message
        { id = build_ast node.id
        ; value =
            bind_null node.value
            (*(Js.Nullable.bind
              node.value (*[%bs.raw{|node.value|}] *)
              (fun x -> build_ast x)) (* build_ast *) *)
        ; attributes = bind_array node.attributes
        ; comment = bind_null node.comment
        }
  | "Term" ->
      Term
        { id = build_ast node.id
        ; value = bind_null node.value
        ; attributes = bind_array node.attributes
        ; comment = bind_null node.comment
        }
  | "Pattern" ->
      Pattern { elements = bind_array node.elements }
  | "TextElement" ->
      TextElement { value = [%bs.raw {|node.value|}] }
  | "Placeable" ->
      Placeable { expression = build_ast node.expression }
  | "StringLiteral" ->
      StringLiteral { value = [%bs.raw {|node.value|}] }
  | "NumberLiteral" ->
      NumberLiteral { value = [%bs.raw {|node.value|}] }
  | "MessageReference" ->
      MessageReference
        { id = build_ast node.id; attribute = bind_null node.attribute }
  | "TermReference" ->
      TermReference
        { id = build_ast node.id
        ; attribute = bind_null node.attribute
        ; arguments = bind_null node.arguments
        }
  | "VariableReference" ->
      VariableReference { id = build_ast node.id }
  | "FunctionReference" ->
      FunctionReference
        { id = build_ast node.id
        ; arguments = build_ast [%bs.raw {|node.arguments|}]
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
        ; value = bind_null [%bs.raw {|node.value|}]
        ; attributes = [||]
        ; comment = Js.Nullable.null
        }
  | "Variant" ->
      Variant
        { key = build_ast node.key
        ; value = build_ast [%bs.raw {|node.value|}]
        ; default = node.default
        }
  | "NamedArgument" ->
      NamedArgument
        { name = build_ast node.name
        ; value = build_ast [%bs.raw {|node.value|}]
        }
  | "Identifier" ->
      Identifier { name = [%bs.raw {|node.name|}] }
  | "Comment" ->
      Comment { content = node.content }
  | "GroupComment" ->
      GroupComment { content = node.content }
  | "ResourceComment" ->
      ResourceComment { content = node.content }
  | "Junk" ->
      Junk { annotations = bind_array node.annotations; content = node.content }
  | "Span" ->
      Span { start = node.start; _end = node._end }
  | "Annotation" ->
      Annotation
        { code = node.code
        ; arguments = [%bs.raw {|node.arguments|}]
        ; message = node.message
        }
  | _ ->
      Junk { annotations = [||]; content = "" }


and bind_null nullable =
  (* Js.Nullable.bind nullable build_ast *)
  match Js.Nullable.toOption nullable with
  | None ->
      (Obj.magic (nullable : 'a Js.Nullable.t) : 'b Js.Nullable.t)
  | Some x ->
      Js.Nullable.return (build_ast x)


and bind_array arr = Belt.Array.map arr build_ast
