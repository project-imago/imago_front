let header_dark_mode lc =
(match lc with
| "fr" ->
{js|Mode nuit|js}
| _ ->
{js|Dark mode|js})


let header_light_mode lc =
(match lc with
| "fr" ->
{js|Mode jour|js}
| _ ->
{js|Light mode|js})


let header_login lc =
(match lc with
| "fr" ->
{js|Connexion|js}
| _ ->
{js|Login|js})


let header_logout lc =
(match lc with
| "fr" ->
{js|Déconnexion|js}
| _ ->
{js|Logout|js})


let header_profile lc =
(match lc with
| "fr" ->
{js|Profil|js}
| _ ->
{js|Profile|js})


let header_settings lc =
(match lc with
| "fr" ->
{js|Paramètres|js}
| _ ->
{js|Settings|js})


let header_toggle_menu lc =
(match lc with
| "fr" ->
{js|Afficher le menu|js}
| _ ->
{js|Toggle menu|js})
