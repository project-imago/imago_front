type color_theme =
  | Dark
  | Light

type model =
  { matrix_client : Matrix.client ref
  ; current_color_theme : color_theme
  ; current_locale : string ref
  }

let init matrix_client =
  { current_color_theme = Dark; current_locale = Locale.init; matrix_client }


type msg =
  | GoTo of Router.route
  | ChangeColorTheme of color_theme
  | ChangeLocale of string
  | ToggleMenu
[@@bs.deriving { accessors }]

let update model = function
  | ChangeColorTheme Light ->
      ({ model with current_color_theme = Light }, Tea.Cmd.none)
  | ChangeColorTheme Dark ->
      ({ model with current_color_theme = Dark }, Tea.Cmd.none)
  | ChangeLocale lc ->
      model.current_locale := lc ;
      (model, Tea.Cmd.none)
  | GoTo _route ->
      (model, Tea.Cmd.none)
  | ToggleMenu ->
      (* should not happen *)
      (model, Tea.Cmd.none)


let view model =
  let open Tea.Html in
  let logo =
    li
      [id "logo"]
      [ Router.link goTo Index [ h1 [] [ text "Imago" ] ] ]
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
    li [] [ Components.header_link_simple msg "moon" label ]
  in
  let logout_button =
    li [] [ Components.header_link_simple (GoTo Logout) "sign-out" "Logout" ]
  in
  let login_button =
    li [] [ Components.header_link goTo Login "sign-in" "Login" ]
  in
  (* let signup_button = *)
  (*   li [] [ Components.rpill_button (GoTo Signup) "sign-in" "Register" ] *)
  (* in *)
  let profile_button =
    li [] [ Components.header_link goTo Index "user" "Profile" ]
  in
  let settings_button =
    li [] [ Components.header_link goTo Index "settings" "Settings" ]
  in
  let hamburger_button =
    li [] [ Components.header_link_simple ~icon_only:true ToggleMenu "menu" "Toggle menu"]
  in
  let locale_dropdown =
    li
      []
      [ a [ href "#" ] [ text !(model.current_locale) ]
      ; ul
          [ class' "dropdown" ]
          [ li [] [ a [ href "#"; onClick (ChangeLocale "en") ] [ text "en" ] ]
          ; li [] [ a [ href "#"; onClick (ChangeLocale "fr") ] [ text "fr" ] ]
          ]
      ]
  in
  let profile_dropdown inside_links =
    let button_text = match (Matrix.current_user_name model.matrix_client) with
    | Some name -> name
    | None -> "Profile"
    in
    li
      []
      (* [ a [ href "#" ] [ text button_text ] *)
      [ Components.header_fake_link "user" button_text
      ; ul
          [ class' "dropdown" ]
          inside_links
      ]
  in
  let settings_dropdown inside_links =
    li
      []
      (* [ a [ href "#" ] [ text "settings" ] *)
      [ Components.header_fake_link "options" "Settings"
      ; ul
          [ class' "dropdown" ]
          inside_links
      ]
  in
  let items_list =
    if Auth.is_logged_in model.matrix_client
    then
      (* [ hamburger_button *)
      (* ; logo *)
      (* ; profile_button *)
      (* ; settings_button *)
      (* ; logout_button *)
      (* ; change_theme_button *)
      (* ] *)
      [ hamburger_button
      ; logo
      ; locale_dropdown
      ; profile_dropdown [profile_button; logout_button]
      ; settings_dropdown [settings_button; change_theme_button]
      ]
    else
      [ hamburger_button
      ; logo
      ; locale_dropdown
      ; login_button (* ; signup_button *)
      ; change_theme_button
      ]
  in
  header [] [ nav [] [ ul [] items_list ] ]
