external isHotEnabled : bool = "hot" [@@bs.val] [@@bs.scope "module"]

external hotAccept : unit -> unit = "accept"
  [@@bs.val] [@@bs.scope "module", "hot"]

let _ =
  if isHotEnabled then hotAccept () ;

  Js.Global.setTimeout
    (fun _ -> App.main (Web.Document.getElementById "main") () |. ignore)
    0
