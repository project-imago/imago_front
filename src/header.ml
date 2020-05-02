type msg =
  | GoTo of Router.route
  [@@bs.deriving {accessors}]

let view signedIn userId =
  let open Tea.Html in
  header []
  [
    div [id "auth-status"]
    (if signedIn then
      [ p [] [(text userId)];
        button [ onClick (GoTo Logout)] [text "Logout"]
      ]
     else
       [ p [] [(text "disconnected")];
       ]);
    Router.link goTo Index
    (div [id "logo"] [h1 [] [text "Imago"]]);
  ]

