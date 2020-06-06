type property = string

type obj =
  { item : string
  ; label : string
  ; description : string
  }

module StmCmp = Belt.Id.MakeComparable (struct
  type t = property

  let cmp a b = String.compare a b
end)

type t = (StmCmp.t, obj array, StmCmp.identity) Belt.Map.t

let empty : t = Belt.Map.make ~id:(module StmCmp)

(* let create_group (_statements : t) = () *)

let set_statements statements property objs =
  Belt.Map.update statements property (fun _ -> Some objs)

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
