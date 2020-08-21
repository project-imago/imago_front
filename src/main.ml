external isHotEnabled : bool = "hot" [@@bs.val] [@@bs.scope "module"]

external hotAccept : string array -> (unit -> unit) -> unit = "accept"
  [@@bs.val] [@@bs.scope "module", "hot"]

let container () = Web.Document.getElementById "main"

let start_app () =
  App.start_app (container ())

let start_dev_app cachedModel =
  App.start_dev_app (container ()) cachedModel

let run () =
  if isHotEnabled && Config.env == "development"
  then begin
    let shutdown_fun = ref (start_dev_app None) in
    hotAccept
      [|"./app.bs.js"|]
      (fun _ ->
        shutdown_fun := start_dev_app (!shutdown_fun ());
        ()
      )
  end
  else start_app ()

let _ =
  Js.Global.setTimeout
    (fun _ -> run () |. ignore)
    0
