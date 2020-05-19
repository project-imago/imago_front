type msg = GoTo of Router.route [@@bs.deriving { accessors }]

type model = { matrix_client : Matrix.client ref }

let init matrix_client = { matrix_client }

let update model = function GoTo _ -> (model, Tea.Cmd.none)

let view _model room_id =
  let open Tea.Html in
  div ~unique:"group" ~key:room_id [] []
