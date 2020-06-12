type msg = GoTo of Router.route [@@bs.deriving { accessors }]

let view matrix_client =
  let open Tea.Html in
  let logo =
    Router.link ~props:[ id "logo" ] goTo Index [ h1 [] [ text "Imago" ] ]
  in
  let signout_button =
    button
      [ onClick (GoTo Logout)
      ; Icons.aria_label "Logout"
      ; class' "icon logout-button round"
      ]
      [ Icons.icon "sign-out" ]
  in
  let login_button =
    button
      [ onClick (GoTo Login)
      ; Icons.aria_label "Login"
      ; class' "icon logout-button pill"
      ]
      [ Icons.icon "sign-in"; text "Log in" ]
  in
  let signup_button =
    button
      [ onClick (GoTo Signup)
      ; Icons.aria_label "Register"
      ; class' "icon logout-button pill"
      ]
      [ Icons.icon "sign-out"; text "Register" ]
  in
  header
    []
    ( if Auth.is_logged_in matrix_client
    then [ logo; p [] [ text (Auth.user_id matrix_client) ]; signout_button ]
    else [ logo; login_button; signup_button ] )
