type router_title_params = { page : string }
let router_title (params : router_title_params)  =
(match !Locale.get with
| "fr" ->
(match params.page with
| "login" ->
{js|Connexion – Imago|js}
| "signup" ->
{js|Nouveau compte – Imago|js}
| "logout" ->
{js|Déconnexion – Imago|js}
| "create-group" ->
{js|Nouveau groupe – Imago|js}
| "create-chat" ->
{js|Nouvelle conversation – Imago|js}
| "chat" ->
{js|Chat – Imago|js}
| "group" ->
{js|Groupe – Imago|js}
| _ ->
{js|Imago|js})

| _ ->
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
)


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
(match !Locale.get with
| "fr" ->
{js|Nom d'utilisateur|js}
| _ ->
{js|Username|js})


let login_password_label () =
(match !Locale.get with
| "fr" ->
{js|Mot de passe|js}
| _ ->
{js|Password|js})


let login_submit () =
(match !Locale.get with
| "fr" ->
{js|Envoyer|js}
| _ ->
{js|Login|js})


let login_no_account_yet () =
(match !Locale.get with
| "fr" ->
{js|Pas encore de compte ?|js}
| _ ->
{js|No account yet?|js})


let login_register_button () =
(match !Locale.get with
| "fr" ->
{js|Créer un compte|js}
| _ ->
{js|Register|js})


let signup_username_label () =
(match !Locale.get with
| "fr" ->
{js|Nom d'utilisateur|js}
| _ ->
{js|Username|js})


let signup_password_label () =
(match !Locale.get with
| "fr" ->
{js|Mot de passe|js}
| _ ->
{js|Password|js})


let signup_submit () =
(match !Locale.get with
| "fr" ->
{js|Envoyer|js}
| _ ->
{js|Register|js})


let content_welcome () =
(match !Locale.get with
| "fr" ->
{js|Bienvenue sur Imago !|js}
| _ ->
{js|Welcome on Imago!|js})


let sidebar_new_chat () =
(match !Locale.get with
| "fr" ->
{js|Nouvelle conversation|js}
| _ ->
{js|New chat|js})


let sidebar_outside_groups () =
(match !Locale.get with
| "fr" ->
{js|En-dehors des groupes|js}
| _ ->
{js|Outside groups|js})


let sidebar_create_group () =
(match !Locale.get with
| "fr" ->
{js|Créer un groupe|js}
| _ ->
{js|Create group|js})


let group_links_title () =
(match !Locale.get with
| "fr" ->
{js|Liens|js}
| _ ->
{js|Links|js})


let group_chats_title () =
(match !Locale.get with
| "fr" ->
{js|Conversations|js}
| _ ->
{js|Chats|js})


let group_events_title () =
(match !Locale.get with
| "fr" ->
{js|Évènements|js}
| _ ->
{js|Events|js})


let group_room_not_found () =
(match !Locale.get with
| "fr" ->
{js|Salon introuvable|js}
| _ ->
{js|Room not found|js})


let chat_room_not_found () =
(match !Locale.get with
| "fr" ->
{js|Salon introuvable|js}
| _ ->
{js|Room not found|js})


type chat_message_date_params = { date : Js.Date.t }
let chat_message_date (params : chat_message_date_params)  =
(match !Locale.get with
| "fr" ->
(Fluent.datetime_format params.date (Fluent.Runtime.make_datetime_params ~day:"2-digit" ~month:"2-digit" ~year:"2-digit" ~hour:"2-digit" ~minute:"2-digit" ~second:"2-digit"()) !Locale.get)
| _ ->
(Fluent.datetime_format params.date (Fluent.Runtime.make_datetime_params ~day:"2-digit" ~month:"2-digit" ~year:"2-digit" ~hour:"2-digit" ~minute:"2-digit" ~second:"2-digit"()) !Locale.get))


let create_chat_name_label () =
(match !Locale.get with
| "fr" ->
{js|Nom|js}
| _ ->
{js|Name|js})


let create_chat_topic_label () =
(match !Locale.get with
| "fr" ->
{js|Description|js}
| _ ->
{js|Topic|js})


let create_chat_submit () =
(match !Locale.get with
| "fr" ->
{js|Créer|js}
| _ ->
{js|Create|js})
