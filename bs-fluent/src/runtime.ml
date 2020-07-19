type number_params2 =
  { currencyDisplay : string (* symbol narrowSymbol code name *)
  ; useGrouping : bool
  ; minimumIntegerDigits : int
  ; minimumFractionDigits : int
  ; maximumFractionDigits : int
  ; minimumSignificantDigits : int
  ; maximumSignificantDigits : int
  ; style : string (* decimal currency percent unit *)
  ; currency : string (* ISO 4217 *)
  }

type number_params3 =
  < currency : string Js.undefined
  ; currencyDisplay : string Js.undefined
  ; maximumFractionDigits : int Js.undefined
  ; maximumSignificantDigits : int Js.undefined
  ; minimumFractionDigits : int Js.undefined
  ; minimumIntegerDigits : int Js.undefined
  ; minimumSignificantDigits : int Js.undefined
  ; style : string Js.undefined
  ; useGrouping : bool Js.undefined >
  Js.t

type datetime_params =
  { (* hour12 : bool*)
    weekday : string (* long short narrow *)
  ; era : string (*long short narrow *)
  ; year : string (*numeric 2-digit *)
  ; month : string (* numeric 2-digit long short narrow *)
  ; day : string (* numeric 2-digit *)
  ; hour : string (* numeric 2-digit *)
  ; minute : string (* numeric 2-digit *)
  ; second : string (* numeric 2-digit *)
  ; timeZoneName : string (* long short *)
  ; timeZone : string
  }

type plural_params = { _type : string (* cardinal ordinal *) }

external make_number_params :
     ?currencyDisplay:string (* symbol narrowSymbol code name *)
  -> ?useGrouping:bool
  -> ?minimumIntegerDigits:int
  -> ?minimumFractionDigits:int
  -> ?maximumFractionDigits:int
  -> ?minimumSignificantDigits:int
  -> ?maximumSignificantDigits:int
  -> ?style:string (* decimal currency percent unit *)
  -> ?currency:string (* ISO 4217 *)
  -> unit
  -> number_params3 = ""
  [@@bs.obj]

external make_datetime_params :
     ?hour12:bool
  -> ?weekday:string (* long short narrow *)
  -> ?era:string (*long short narrow *)
  -> ?year:string (*numeric 2-digit *)
  -> ?month:string (* numeric 2-digit long short narrow *)
  -> ?day:string (* numeric 2-digit *)
  -> ?hour:string (* numeric 2-digit *)
  -> ?minute:string (* numeric 2-digit *)
  -> ?second:string (* numeric 2-digit *)
  -> ?timeZoneName:string (* long short *)
  -> ?timeZone:string
  -> unit
  -> datetime_params = ""
  [@@bs.obj]

external make_plural_params :
  ?_type:string (* cardinal ordinal *) -> unit -> plural_params = ""
  [@@bs.obj]

type nf

type pr

type dtf

external new_nf : string -> number_params3 -> nf = "Intl.NumberFormat"
  [@@bs.new]

external new_pr : string -> plural_params -> pr = "Intl.PluralRules" [@@bs.new]

external new_dtf : string -> datetime_params -> dtf = "Intl.DateTimeFormat"
  [@@bs.new]

external nf : nf -> int -> string = "format" [@@bs.send]

external pr : pr -> int -> string = "select" [@@bs.send]

external dtf : dtf -> int -> string = "format" [@@bs.send]

type number_params = { _type : string }

(* type simplified_part = *)
(*   | Literal of literal *)
(*   | List of simplified_part list *)

(* type part = *)
(*   | String of string *)
(*   | Int of int *)
(*   | Select of literal * string * part Js.Dict.t *)
(*   | Isol of int *)
(*   | List of part list *)

(* type literal = *)
(*   | String of string *)
(*   | Int of int *)

(* module LiteralCmp = Belt.Id.MakeComparable (struct *)
(*   type t = literal *)

(*   let cmp a b = *)
(*     match (a, b) with *)
(*     | String x, String y -> *)
(*         String.compare x y *)
(*     | Int x, Int y -> *)
(*         Pervasives.compare x y *)
(*     | Int _, _ -> *)
(*         -1 *)
(*     | String _, _ -> *)
(*         1 *)
(* end) *)

(* type variant *)

(* type t = (LiteralCmp.t, variant, LiteralCmp.identity) Belt.Map.t *)

(* type 'a message_fun = 'a -> string -> string *)

(* type 'a term_fun = 'a -> string -> string *)

(* type 'a element = *)
(*   | Literal of literal *)
(*   | TermRef of 'a term_fun * 'a *)
(*   | MessageRef of 'a message_fun * 'a *)
(*   | FunRef of 'a global_functions *)
(*   | Select of 'a element * literal * (literal * 'a element) array *)
(*   | List of 'a element list *)

(* and 'a global_functions = *)
(*   | NUMBER of number_params3 * int *)
(*   | ISOL of string *)
(* [@@bs.deriving { accessors }] *)

(* type 'a pattern = 'a element list *)

(* (1* type 'a message = part list *1) *)

(* (1* let execute_select value default_value variants = *1) *)
(* (1* match value with *1) *)
(* (1*   | Int i -> *1) *)
(* (1*       let is = string_of_int i in *1) *)
(* (1*       j *1) *)

(* type simplified = *)
(*   | Literal of literal *)
(*   | SList of simplified list *)

(* let rec compress (simplified : simplified) = *)
(*   match simplified with *)
(*   | Literal (String s) -> *)
(*       s *)
(*   | Literal (Int i) -> *)
(*       nf (new_nf "en" (make_number_params3 ())) i *)
(*   | SList l -> *)
(*       Tablecloth.List.map l ~f:compress |> Tablecloth.String.join ~sep:"" *)


(* let rec execute (element : 'a element) = *)
(*   match element with *)
(*   | Select (value, default_value, variants) -> *)
(*       let variants_map = Belt.Map.fromArray variants ~id:(module LiteralCmp) in *)
(*       let executed_value = execute value in *)
(*       ( match executed_value with *)
(*       | Literal (String s) -> *)
(*           Belt.Map.get variants_map (String s) *)
(*           |> Tablecloth.Option.orElse (Belt.Map.get variants_map default_value) *)
(*           |> Tablecloth.Option.getExn *)
(*           |> execute *)
(*       | Literal (Int i) -> *)
(*           let plural_form : literal = *)
(*             String (pr (new_pr "en" (make_plural_params ())) i) *)
(*           in *)
(*           Belt.Map.get variants_map (Int i) *)
(*           |> Tablecloth.Option.orElse (Belt.Map.get variants_map plural_form) *)
(*           |> Tablecloth.Option.orElse (Belt.Map.get variants_map default_value) *)
(*           |> Tablecloth.Option.getExn *)
(*           |> execute ) *)
(*   | FunRef (NUMBER (params, value)) -> *)
(*       Literal (String (nf (new_nf "en" params) value)) *)
(*   | FunRef (ISOL value) -> *)
(*       Literal (String "str") *)
(*   | Literal (String s) -> *)
(*       Literal (String s) *)
(*   | Literal (Int i) -> *)
(*       Literal (Int i) *)
(*   | TermRef (fn, params) -> *)
(*       Literal (String "str") *)
(*   | MessageRef (fn, params) -> *)
(*       Literal (String "str") *)
(*   | List l -> *)
(*       SList (Tablecloth.List.map l ~f:execute) *)


(* let rec msgString lc (message : simplified) = compress message *)

(* (1* |> Tablecloth.List.map ~f:(fun part -> *1) *)
(* (1*     match part with *1) *)
(* (1*     | _ -> "str" *1) *)
(* (1* | String str -> str *1) *)
(* (1* | Int i -> nf lc i *1) *)
(* (1* | List l -> msgString lc l *1) *)

(* let formatString message = execute message |> msgString "en" *)
