let ()  =
  Plugin.process_files [|"./test/en.ftl"|] "./test_output.ml" "en"
  Js.Nullable.null
