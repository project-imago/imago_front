# title =
#     .index = Imago
#     .login = Imago – Login
#     .signup = Imago – Register
#     .logout = Imago – Logout
#     .create-group = Imago – New group
#     .create-chat = Imago – New chat
#     .chat = Imago – Chat
#     .group = Imago – Group

router =
    .title =
        { $page ->
           *[index] Imago
            [login] Connexion – Imago
            [signup] Nouveau compte – Imago
            [logout] Déconnexion – Imago
            [create-group] Nouveau groupe – Imago
            [create-chat] Nouvelle conversation – Imago
            [chat] Chat – Imago
            [group] Groupe – Imago
        }
header =
    .settings = Paramètres
    .profile = Profil
    .login = Connexion
    .logout = Déconnexion
    .dark-mode = Mode nuit
    .light-mode = Mode jour
    .toggle-menu = Afficher le menu
login =
    .username-label = Nom d'utilisateur
    .password-label = Mot de passe
    .submit = Envoyer
    .no-account-yet = Pas encore de compte ?
    .register-button = Créer un compte
signup =
    .username-label = Nom d'utilisateur
    .password-label = Mot de passe
    .submit = Envoyer
content =
    .welcome = Bienvenue sur Imago !
sidebar =
    .new-chat = Nouvelle conversation
    .outside-groups = En-dehors des groupes
    .create-group = Créer un groupe
group =
    .links-title = Liens
    .chats-title = Conversations
    .events-title = Évènements
    .room-not-found = Salon introuvable
chat =
    .room-not-found = Salon introuvable
    .message-date = { DATETIME($date, day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit") }
