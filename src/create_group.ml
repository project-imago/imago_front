type model =
  {
    matrix_client : Matrix.client ref;
  }

let init matrix_client =
  {
      matrix_client;
  }

type msg =
  | GoTo of Router.route
  [@@bs.deriving {accessors}]

let view model =
  let open Tea.Html in
  div [] []
