(* const { FluentParser } = require('fluent-syntax') *)
(* const FluentCompiler = require('./compiler2') *)

(* const parser = new FluentParser() *)
(* const absolutePath = path.resolve(filePath); *)
(* const content = fs.readFileSync(absolutePath, { encoding: 'utf-8' }); *)
(* const source = parser.parse(this.svgList[0].content) *)
(* const fluent_compiler = new FluentCompiler({}) *)
(* const js = fluent_compiler.compile("en", source) *)
(* fs.writeFileSync('./src/t.ml', js) *)

external resolve_path : string -> string = "resolve"
  [@@bs.module "path"] [@@bs.val]

external read_file :
  string -> (_[@bs.as {json|{"encoding": "utf-8"}|json}]) -> string =
    "readFileSync"
  [@@bs.module "fs"] [@@bs.val]

external write_file : string -> string -> unit = "writeFileSync"
  [@@bs.module "fs"] [@@bs.val]

type parser = < parse : string -> Ast.js_node [@bs.meth] > Js.t

(* type compiler = < compile : string -> string -> string [@bs.meth] > Js.t *)

external new_parser : unit -> parser = "FluentParser"
  [@@bs.new] [@@bs.module "fluent-syntax"]

(* external new_compiler : unit -> compiler = "Compiler" *)
(*   [@@bs.new] [@@bs.module "./compiler"] *)

let get_lc path =
  Js.String.splitByRe [%re "/[\.\/]/"] path
  |. Belt.Array.reverse
  |. Belt.Array.keepMap (function
    | Some part -> Js.log part; Some part
    | None -> None)
  |> Js.Array.find (fun part ->
    (match Js.String.match_ [%re "/^[a-z]{2}(-[A-Z]{2})?$/"] part with
    | Some _substr -> true
    | None -> false
    )
  )
  |. Belt.Option.getExn


let process_files sources dest default_lc locale_getter =
  (* let file_path = Js.Array.unsafe_get source 0 in *)
  let parser = new_parser () in
  (* let compiler = new_compiler () in *)
  let asts = Belt.Array.map sources (fun source ->
    let lc = get_lc source in
    let absolute_path = resolve_path source in
    let content = read_file absolute_path in
    let ast = parser##parse content in
    Compiler.precompile ast lc
    ) in
  (* let () = Js.log ast in *)
  let output = Compiler.compile asts default_lc locale_getter in
  let () = write_file dest output in
  ()


