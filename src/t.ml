type router_title_params = { page : string }
let router_title (params : router_title_params)  =
(match params.page with
| "login" ->
{js|Login – Imago|js}
| "signup" ->
{js|Register – Imago|js}
| "logout" ->
{js|Logout – Imago|js}
| "create-group" ->
{js|New group – Imago|js}
| "create-chat" ->
{js|New chat – Imago|js}
| "chat" ->
{js|Chat – Imago|js}
| "group" ->
{js|Group – Imago|js}
| _ ->
{js|Imago|js})


let header_settings () =
(match !Locale.get with
| "fr" ->
{js|Paramètres|js}
| _ ->
{js|Settings|js})


let header_profile () =
(match !Locale.get with
| "fr" ->
{js|Profil|js}
| _ ->
{js|Profile|js})


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


let header_toggle_menu () =
(match !Locale.get with
| "fr" ->
{js|Afficher le menu|js}
| _ ->
{js|Toggle menu|js})


let login_username_label () =
{js|Username|js}

let login_password_label () =
{js|Password|js}

let login_submit () =
{js|Login|js}

let login_no_account_yet () =
{js|No account yet?|js}

let login_register_button () =
{js|Register|js}

let signup_username_label () =
{js|Username|js}

let signup_password_label () =
{js|Password|js}

let signup_submit () =
{js|Register|js}

let content_welcome () =
{js|Welcome on Imago!|js}

let sidebar_new_chat () =
{js|New chat|js}

let sidebar_outside_groups () =
{js|Outside groups|js}

let sidebar_create_group () =
{js|Create group|js}

let group_links_title () =
{js|Links|js}

let group_chats_title () =
{js|Chats|js}

let group_events_title () =
{js|Events|js}

let group_room_not_found () =
{js|Room not found|js}

let chat_room_not_found () =
{js|Room not found|js}