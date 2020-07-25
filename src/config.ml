(* type env = *)
(*   | Production *)
(*   | Development *)

(* type config = *)
(*   < env : env *)
(*   ; matrix_url : string *)
(*   ; api_url : string *)
(*   > Js.t *)

(* external config : config = "process.env" [@@bs.val] *)

external env : string = "process.env.NODE_ENV" [@@bs.val]

external matrix_url : string = "matrix_url" [@@bs.val]
external api_url : string = "api_url" [@@bs.val]
