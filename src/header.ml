type msg =
  | GoTo of Router.route
  [@@bs.deriving {accessors}]

let view matrix_client =
  let open Tea.Html in
  header []
  [
    div [id "auth-status"]
    (if (Auth.is_logged_in matrix_client) then
      [ p [] [(text (Auth.user_id matrix_client))];
        button [ onClick (GoTo Logout)] [text "Logout"]
      ]
     else
       [ p [] [(text "disconnected")];
       ]);
    Router.link goTo Index
    (div [id "logo"] [h1 [] [text "Imago"]]);
  ]

