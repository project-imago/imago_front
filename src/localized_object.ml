
type t = < label : string Js.Dict.t ; description : string Js.Dict.t > Js.t

let get_localized dict lc =
  Js.Dict.get dict lc
  |. Tablecloth.Option.or_ (Js.Dict.get dict "en")
  |. Tablecloth.Option.or_
       (Js.Dict.values dict |> Tablecloth.Array.get_at ~index:0)
  |> Tablecloth.Option.with_default ~default:""

let to_text obj =
  get_localized obj##label !Locale.get
  ^ " ("
  ^ get_localized obj##description !Locale.get
  ^ ")"
