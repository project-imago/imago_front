module Statements = struct
  type property = string
  type obj = {item : string; label : string; description : string}

  module StmCmp =
    Belt.Id.MakeComparable
    (struct
      type t = property
      let cmp a b = String.compare a b
    end)

  type t = (StmCmp.t, (obj array), StmCmp.identity) Belt.Map.t

  let empty : t =
    Belt.Map.make ~id:(module StmCmp)
end

let create_group (statements: Statements.t) =
  ()
