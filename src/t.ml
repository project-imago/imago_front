let header_dark_mode () =
(match !Locale.get with
| "fr" ->
{js|Mode nuit|js}
| _ ->
{js|Dark mode|js})


let header_light_mode () =
(match !Locale.get with
| "fr" ->
{js|Mode jour|js}
| _ ->
{js|Light mode|js})


let header_login () =
(match !Locale.get with
| "fr" ->
{js|Connexion|js}
| _ ->
{js|Login|js})


let header_logout () =
(match !Locale.get with
| "fr" ->
{js|Déconnexion|js}
| _ ->
{js|Logout|js})


let header_profile () =
(match !Locale.get with
| "fr" ->
{js|Profil|js}
| _ ->
{js|Profile|js})


let header_settings () =
(match !Locale.get with
| "fr" ->
{js|Paramètres|js}
| _ ->
{js|Settings|js})


let header_toggle_menu () =
(match !Locale.get with
| "fr" ->
{js|Afficher le menu|js}
| _ ->
{js|Toggle menu|js})
