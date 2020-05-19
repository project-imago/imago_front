(* [%raw {|require.context('../../../node_modules/bytesize-icons/dist/icons', false, /\.svg$/)|}] *)

let aria_label label = Vdom.attribute "" "aria-label" label

let icon ?(path = "") ?(prefix = "") name =
  let href = path ^ "#" ^ prefix ^ name in
  let open Vdom in
  fullnode
    "http://www.w3.org/2000/svg"
    "svg"
    ""
    ""
    [ attribute "" "class" "icon"
    ; attribute "" "aria-hidden" "true"
    ; attribute "" "focusable" "false"
    ]
    [ fullnode
        "http://www.w3.org/2000/svg"
        "use"
        ""
        ""
        [ attribute "" "href" href ]
        []
    ]
