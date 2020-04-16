type msg =
  | GoTo of Router.route

let view signedIn userId =
  let open Tea.Html in
  header [ style "text-weight" "bold" ]
    (if signedIn then
      [ p [] [(text userId)];
        button [ onClick (GoTo Logout)] [text "Logout"]
      ]
     else
       [ p [] [(text "disconnected")];
        button [ onClick (GoTo Index)] [text "Index"]
       ])

