// Generated by BUCKLESCRIPT, PLEASE EDIT WITH CARE
'use strict';

var Fs = require("fs");
var Path = require("path");
var Compiler = require("./compiler.bs.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Belt_Option = require("bs-platform/lib/js/belt_Option.js");
var Caml_option = require("bs-platform/lib/js/caml_option.js");
var FluentSyntax = require("fluent-syntax");

function get_lc(path) {
  return Belt_Option.getExn(Caml_option.undefined_to_opt(Belt_Array.keepMap(Belt_Array.reverse(path.split(/[\.\/]/)), (function (part) {
                          if (part !== undefined) {
                            return part;
                          }
                          
                        })).find((function (part) {
                        var _substr = part.match(/^[a-z]{2}(-[A-Z]{2})?$/);
                        return _substr !== null;
                      }))));
}

function process_files(sources, dest, default_lc, locale_getter) {
  var parser = new FluentSyntax.FluentParser();
  var asts = Belt_Array.map(sources, (function (source) {
          var lc = get_lc(source);
          var absolute_path = Path.resolve(source);
          var content = Fs.readFileSync(absolute_path, ({"encoding": "utf-8"}));
          var ast = parser.parse(content);
          return Compiler.precompile(ast, lc);
        }));
  var output = Compiler.compile(asts, default_lc, locale_getter);
  Fs.writeFileSync(dest, output);
  
}

exports.get_lc = get_lc;
exports.process_files = process_files;
/* fs Not a pure module */