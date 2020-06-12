type color_theme =
  | Dark
  | Light

type model =
  { matrix_client : Matrix.client ref
  ; current_color_theme : color_theme
  }

let init matrix_client = { current_color_theme = Dark; matrix_client }

type msg =
  | GoTo of Router.route
  | ChangeColorTheme of color_theme
[@@bs.deriving { accessors }]

let update model = function
  | ChangeColorTheme Light ->
      ({ model with current_color_theme = Light }, Tea.Cmd.none)
  | ChangeColorTheme Dark ->
      ({ model with current_color_theme = Dark }, Tea.Cmd.none)
  | GoTo _route ->
      (model, Tea.Cmd.none)


let view model =
  let open Tea.Html in
  let logo =
    Router.link ~props:[ id "logo" ] goTo Index [ h1 [] [ text "Imago" ] ]
  in
  let change_theme_button =
    let msg =
      match model.current_color_theme with
      | Dark ->
          ChangeColorTheme Light
      | Light ->
          ChangeColorTheme Dark
    in
    let label =
      match model.current_color_theme with
      | Dark ->
          "Light mode"
      | Light ->
          "Dark mode"
    in
    button
      [ onClick msg; Icons.aria_label label; class' "icon theme-button round" ]
      [ Icons.icon "moon"]
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
      ; class' "icon login-button pill"
      ]
      [ Icons.icon "sign-in"; text "Log in" ]
  in
  let signup_button =
    button
      [ onClick (GoTo Signup)
      ; Icons.aria_label "Register"
      ; class' "icon signup-button pill"
      ]
      [ Icons.icon "sign-in"; text "Register" ]
  in
  header
    []
    ( if Auth.is_logged_in model.matrix_client
    then
      [ logo
      ; p [] [ text (Auth.user_id model.matrix_client) ]
      ; signout_button
      ; change_theme_button
      ]
    else [ logo; login_button; signup_button; change_theme_button  ] )
