type labeled_object = <iri : string ; label : string ; description : string> Js.t

module StmCmp = Belt.Id.MakeComparable (struct
  type t = labeled_object

  let cmp a b = String.compare a##iri b##iri
end)

type t = (StmCmp.t, labeled_object array, StmCmp.identity) Belt.Map.t

let empty : t = Belt.Map.make ~id:(module StmCmp)

let add_statements statements property obj =
  Belt.Map.update statements property (function
      | None ->
          Some (Belt.Array.make 1 obj)
      | Some objs ->
          Some (Belt.Array.concat objs [| obj |]))

let remove_obj statements property obj =
  Belt.Map.update statements property (function
      | None ->
          None
      | Some objs ->
          Some (Belt.Array.keep objs (fun x -> x <> obj)))

let obj_to_text obj =
  obj##label
  ^ " ("
  ^ obj##description
  ^ ")"

let from_localized_object iri obj lc =
  [%bs.obj {
    iri;
    label = Localized_object.get_localized obj##label lc;
  description = Localized_object.get_localized obj##description lc
  }]

