type node = < iri : string ; label : string ; description : string > Js.t

(* type node = *)
(*   { iri : string *)
(*   ; label : string *)
(*   ; description : string *)
(*   } *)

type property = node

type obj = node

module StmCmp = Belt.Id.MakeComparable (struct
  type t = property

  let cmp a b = String.compare a##iri b##iri
end)

type t = (StmCmp.t, obj array, StmCmp.identity) Belt.Map.t

module StatementState = Matrix.Client.MakeStateAccessors (struct
  (* type node = < iri : string ; label : string > Js.t *)

  type t =
    < statements : < property : property ; _object : obj > Js.t array > Js.t
end)

let empty : t = Belt.Map.make ~id:(module StmCmp)

(* let create_group (_statements : t) = () *)

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


let map = Belt.Map.map

let build_from_state (state : StatementState.event) =
  (state##getContent ())##statements
  |> Tablecloth.Array.fold_left ~initial:empty ~f:(fun statement acc ->
         add_statements acc statement##property statement##_object)

let to_state (statements : t) =
  statements
  |> Belt.Map.toList
  |. Belt.List.map (fun (property, obj_array) ->
      obj_array
      |> Belt.List.fromArray
      |. Belt.List.map (fun obj ->
        [%bs.obj {property = property; _object = obj}]))
  |> Belt.List.flatten
  |> Belt.List.toArray

