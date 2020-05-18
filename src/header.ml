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
        button
          [ onClick (GoTo Logout);
            Icons.aria_label "Logout";
            class' "icon logout-button"
          ]
          [Icons.icon "sign-out"]
      ]
     else
       [ p [] [(text "disconnected")];
       ]);
    Router.link goTo Index
    [div [id "logo"] [h1 [] [text "Imago"]]];
  ]

