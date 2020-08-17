type node = string

(* type node = *)
(*   { iri : string *)
(*   ; label : string *)
(*   ; description : string *)
(*   } *)

type property = node

(* type obj = node *)

type iri = string

module StmCmp = Belt.Id.MakeComparable (struct
  type t = property

  let cmp a b = String.compare a b
end)

type t = (StmCmp.t, iri array, StmCmp.identity) Belt.Map.t

module StatementState = Matrix.Client.MakeStateAccessors (struct
  type t = < property : iri ; value : iri > Js.t
end)

module ObjectState = Matrix.Client.MakeStateAccessors (struct
  type t = Localized_object.t
end)

let empty : t = Belt.Map.make ~id:(module StmCmp)

let set_statements statements property objs =
  Belt.Map.set statements property objs

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

let build_from_state_events (events : StatementState.event array) =
  Tablecloth.Array.fold_left ~initial:empty ~f:(fun event acc ->
    let content = event##getContent () in
    add_statements acc content##property content##value
) events
