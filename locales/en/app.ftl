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
    .title = {$page ->
    *[index] Imago
    [login] Login – Imago
    [signup] Register – Imago
    [logout] Logout – Imago
    [create-group] New group – Imago
    [create-chat] New chat – Imago
    [chat] Chat – Imago
    [group] Group – Imago
    }

header =
    .settings = Settings
    .profile = Profile
    .login = Login
    .logout = Logout
    .dark-mode = Dark mode
    .light-mode = Light mode
    .toggle-menu = Toggle menu

login =
    .username-label = Username
    .password-label = Password
    .submit = Login
    .no-account-yet = No account yet?
    .register-button = Register

signup =
    .username-label = Username
    .password-label = Password
    .submit = Register

content =
    .welcome = Welcome on Imago!

sidebar =
    .new-chat = New chat
    .outside-groups = Outside groups
    .create-group = Create group

group =
    .links-title = Links
    .chats-title = Chats
    .events-title = Events
    .room-not-found = Room not found

chat =
    .room-not-found = Room not found
    .message-date = {DATETIME($date, day: "2-digit", month: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit")}

create-chat =
    .name-label = Name
    .topic-label = Topic
    .submit = Create
