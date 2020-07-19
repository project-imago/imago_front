module Runtime = Runtime

let number_format n params lc =
  let nf = Runtime.new_nf lc params in
  Runtime.nf nf n

let plural_rule n ?(_type="cardinal") lc =
  let params = Runtime.make_plural_params ~_type () in
  let pr = Runtime.new_pr lc params in
  Runtime.pr pr n

let datetime_format d params lc =
  let dtf = Runtime.new_dtf lc params in
  Runtime.dtf dtf d
