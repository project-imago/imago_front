let rpill_button msg icon label' =
  let open Tea.Html in
  button
    [ onClick msg
    ; Icons.aria_label label'
    ; title label'
    ; class' "icon rpill"
    ]
    [ Icons.icon icon; span [] [text label'] ]

let rpill_link msg route icon label' =
  let open Tea.Html in
  Router.link
  ~props:[Icons.aria_label label'; class' "button icon rpill"; title label'; ]
  msg
  route
  [ Icons.icon icon; span [] [text label'] ]
