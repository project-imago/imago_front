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
    Components.rpill_button msg "moon" label
  in
  let logout_button =
    Components.rpill_button (GoTo Logout) "sign-out" "Logout"
  in
  let login_button =
    Components.rpill_button (GoTo Login) "sign-in" "Login"
  in
  let signup_button =
    Components.rpill_button (GoTo Signup) "sign-in" "Register"
  in
  let profile_button =
    Components.rpill_link goTo Index "user" "Profile"
  in
  let settings_button =
    Components.rpill_link goTo Index "settings" "Settings"
  in
  header
    []
    ( if Auth.is_logged_in model.matrix_client
    then
      [ logo
      ; profile_button
      ; settings_button
      ; logout_button
      ; change_theme_button
      ]
    else [ logo; login_button; signup_button; change_theme_button ] )
