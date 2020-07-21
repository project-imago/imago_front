// Generated by BUCKLESCRIPT, PLEASE EDIT WITH CARE
'use strict';

var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Caml_chrome_debugger = require("bs-platform/lib/js/caml_chrome_debugger.js");

function build_ast(node) {
  var match = node.type;
  switch (match) {
    case "Annotation" :
        return /* Annotation */Caml_chrome_debugger.variant("Annotation", 23, [{
                    code: node.code,
                    arguments: node.arguments,
                    message: node.message
                  }]);
    case "Attribute" :
        return /* Attribute */Caml_chrome_debugger.variant("Attribute", 14, [{
                    id: build_ast(node.id),
                    value: bind_null(node.value),
                    attributes: [],
                    comment: null
                  }]);
    case "CallArguments" :
        return /* CallArguments */Caml_chrome_debugger.variant("CallArguments", 13, [{
                    positional: Belt_Array.map(node.positional, build_ast),
                    named: Belt_Array.map(node.named, build_ast)
                  }]);
    case "Comment" :
        return /* Comment */Caml_chrome_debugger.variant("Comment", 18, [{
                    content: node.content
                  }]);
    case "FunctionReference" :
        return /* FunctionReference */Caml_chrome_debugger.variant("FunctionReference", 11, [{
                    id: build_ast(node.id),
                    arguments: build_ast(node.arguments)
                  }]);
    case "GroupComment" :
        return /* GroupComment */Caml_chrome_debugger.variant("GroupComment", 19, [{
                    content: node.content
                  }]);
    case "Identifier" :
        return /* Identifier */Caml_chrome_debugger.variant("Identifier", 17, [{
                    name: node.name
                  }]);
    case "Junk" :
        return /* Junk */Caml_chrome_debugger.variant("Junk", 21, [{
                    annotations: Belt_Array.map(node.annotations, build_ast),
                    content: node.content
                  }]);
    case "Message" :
        return /* Message */Caml_chrome_debugger.variant("Message", 1, [{
                    id: build_ast(node.id),
                    value: bind_null(node.value),
                    attributes: Belt_Array.map(node.attributes, build_ast),
                    comment: bind_null(node.comment)
                  }]);
    case "MessageReference" :
        return /* MessageReference */Caml_chrome_debugger.variant("MessageReference", 8, [{
                    id: build_ast(node.id),
                    attribute: bind_null(node.attribute)
                  }]);
    case "NamedArgument" :
        return /* NamedArgument */Caml_chrome_debugger.variant("NamedArgument", 16, [{
                    name: build_ast(node.name),
                    value: build_ast(node.value)
                  }]);
    case "NumberLiteral" :
        return /* NumberLiteral */Caml_chrome_debugger.variant("NumberLiteral", 7, [{
                    value: node.value
                  }]);
    case "Pattern" :
        return /* Pattern */Caml_chrome_debugger.variant("Pattern", 3, [{
                    elements: Belt_Array.map(node.elements, build_ast)
                  }]);
    case "Placeable" :
        return /* Placeable */Caml_chrome_debugger.variant("Placeable", 5, [{
                    expression: build_ast(node.expression)
                  }]);
    case "Resource" :
        return /* Resource */Caml_chrome_debugger.variant("Resource", 0, [{
                    body: Belt_Array.map(node.body, build_ast)
                  }]);
    case "ResourceComment" :
        return /* ResourceComment */Caml_chrome_debugger.variant("ResourceComment", 20, [{
                    content: node.content
                  }]);
    case "SelectExpression" :
        return /* SelectExpression */Caml_chrome_debugger.variant("SelectExpression", 12, [{
                    selector: build_ast(node.selector),
                    variants: Belt_Array.map(node.variants, build_ast)
                  }]);
    case "Span" :
        return /* Span */Caml_chrome_debugger.variant("Span", 22, [{
                    start: node.start,
                    _end: node._end
                  }]);
    case "StringLiteral" :
        return /* StringLiteral */Caml_chrome_debugger.variant("StringLiteral", 6, [{
                    value: node.value
                  }]);
    case "Term" :
        return /* Term */Caml_chrome_debugger.variant("Term", 2, [{
                    id: build_ast(node.id),
                    value: bind_null(node.value),
                    attributes: Belt_Array.map(node.attributes, build_ast),
                    comment: bind_null(node.comment)
                  }]);
    case "TermReference" :
        return /* TermReference */Caml_chrome_debugger.variant("TermReference", 9, [{
                    id: build_ast(node.id),
                    attribute: bind_null(node.attribute),
                    arguments: bind_null(node.arguments)
                  }]);
    case "TextElement" :
        return /* TextElement */Caml_chrome_debugger.variant("TextElement", 4, [{
                    value: node.value
                  }]);
    case "VariableReference" :
        return /* VariableReference */Caml_chrome_debugger.variant("VariableReference", 10, [{
                    id: build_ast(node.id)
                  }]);
    case "Variant" :
        return /* Variant */Caml_chrome_debugger.variant("Variant", 15, [{
                    key: build_ast(node.key),
                    value: build_ast(node.value),
                    default: node.default
                  }]);
    default:
      return /* Junk */Caml_chrome_debugger.variant("Junk", 21, [{
                  annotations: [],
                  content: ""
                }]);
  }
}

function bind_null(nullable) {
  if (nullable == null) {
    return nullable;
  } else {
    return build_ast(nullable);
  }
}

function bind_array(arr) {
  return Belt_Array.map(arr, build_ast);
}

exports.build_ast = build_ast;
exports.bind_null = bind_null;
exports.bind_array = bind_array;
/* No side effect */
