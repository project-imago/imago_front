let rpill_button msg icon label' =
  let open Tea.Html in
  button
    [ onClick msg; Icons.aria_label label'; title label'; class' "icon rpill" ]
    [ Icons.icon icon; span [] [ text label' ] ]


let rpill_link msg route icon label' =
  let open Tea.Html in
  Router.link
    ~props:[ Icons.aria_label label'; class' "button icon rpill"; title label' ]
    msg
    route
    [ Icons.icon icon; span [] [ text label' ] ]


let header_link msg route icon label' =
  let open Tea.Html in
  Router.link
    ~props:[ Icons.aria_label label'; class' ""; title label' ]
    msg
    route
    [ Icons.icon icon; span [] [ text label' ] ]


let header_link_simple ?(icon_only = false) msg icon label' =
  let open Tea.Html in
  a
    [ Icons.aria_label label'
    ; classList [ ("icon-only", icon_only) ]
    ; title label'
    ; href "#"
    ; onClick msg
    ]
    [ Icons.icon icon; span [] [ text label' ] ]

let header_fake_link ?(icon_only = false) icon label' =
  let open Tea.Html in
  a
    [ Icons.aria_label label'
    ; classList [ ("icon-only", icon_only) ]
    ; title label'
    ; href "#"
    ]
    [ Icons.icon icon; span [] [ text label' ] ]
