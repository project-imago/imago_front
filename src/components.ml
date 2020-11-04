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


module ClickDropdown = struct
  type dom_rect =
    < height : int
    ; width : int
    ; top : int
    ; right : int
    ; bottom : int
    ; left : int > Js.t

  let opened : Web.Node.t Js.Nullable.t ref = ref Js.Nullable.null

  let toggle_visibility _elem = [%raw
  {|_elem.classList.toggle('click-dropdown__menu_show')|}]

  let get_rect _elem = [%raw {|_elem.getBoundingClientRect()|}]

  let position dropdown btn =
    let btn_rect : dom_rect = get_rect btn in
    let dropdown_rect : dom_rect = get_rect dropdown in
    let ideal_left_pos = btn_rect##right + 10 in
    let ideal_top_pos = btn_rect##top - 10 in
    let () = if ideal_left_pos + [%raw {|dropdown.offsetWidth|}] < [%raw
    {|document.documentElement.clientWidth|}] then
      let _ = Web.Node.setStyleProperty dropdown "left" (Js.Null.return @@
      string_of_int ideal_left_pos ^ "px") in
      Web.Node.setStyleProperty dropdown "right" (Js.Null.return "unset")
    else
      let _ = Web.Node.setStyleProperty dropdown "right" (Js.Null.return "0") in
      Web.Node.setStyleProperty dropdown "left" (Js.Null.return "unset")
    in
    let () = if ideal_top_pos + dropdown_rect##height < [%raw
    {|document.documentElement.clientHeight|}] then
      let _ = Web.Node.setStyleProperty dropdown "top" (Js.Null.return @@ string_of_int
      ideal_top_pos ^ "px") in
      Web.Node.setStyleProperty dropdown "bottom" (Js.Null.return "unset")
    else
      let _ = Web.Node.setStyleProperty dropdown "bottom" (Js.Null.return "0")
      in
      Web.Node.setStyleProperty dropdown "top" (Js.Null.return "unset")
    in
    ()

  let handle_dropdown elem =
    let dropdown = [%raw {|elem.lastChild|}] in
    Js.log elem ;
    Js.log dropdown ;
    let () = toggle_visibility dropdown in
    opened :=
      match Js.Nullable.toOption !opened with
      | None ->
          let () = position dropdown elem in
          dropdown
      | Some c when c = dropdown ->
          Js.Nullable.null
      | Some c ->
          let () = toggle_visibility c in
          dropdown


  let handle_click : Web.Node.event_cb =
   fun [@bs] event ->
    Js.log event ;
    let nearest_button : Web.Node.t Js.Nullable.t =
      [%raw {|event.target.closest('.click-dropdown')|}]
    in
    match
      (Js.Nullable.toOption nearest_button, Js.Nullable.toOption !opened)
    with
    | Some e, _ ->
        handle_dropdown e
    | _, Some c ->
        let () = toggle_visibility c in
        opened := Js.Nullable.null
    | _, _ ->
        ()


  let _ =
    let document = Web_node.document_node in
    document##addEventListener "click" handle_click false


  let element classes goTo =
    let open Tea.Html in
    div
      [ class' (classes ^ " click-dropdown") ]
      (* ; Tea.Html2.Attributes.tabindex 0 ] *)
      [ button
          [ class' "click-dropdown__button button_round"
          ; Icons.aria_label (T.sidebar_create_group ())
          ; title (T.sidebar_create_group ())
          ]
          [ Icons.icon "plus" ]
      ; ul
          [ class' "click-dropdown__menu" ]
          [ li [class' "click-dropdown__item"] [ header_link goTo Index "settings" (T.header_settings ()) ] ]
      ]
end
