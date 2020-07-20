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
