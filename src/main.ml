

external isHotEnabled :
  bool
  = "hot" [@@bs.val][@@bs.scope "module"]

external hotAccept :
  unit
  -> unit
  = "accept" [@@bs.val][@@bs.scope "module", "hot"]

let _ = if isHotEnabled then hotAccept ();

Js.Global.setTimeout
  (fun _ -> 
  App.main (Js.Nullable.return (Web.Document.body ())) () 
  |. ignore
  )
0
