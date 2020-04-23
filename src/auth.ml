let login_with_password (matrix_client: Matrix.client ref) username password =
 Matrix.login_with_password !matrix_client username password
 |> ignore

let login_with_token (matrix_client: Matrix.client ref) token =
 Matrix.login_with_password !matrix_client token
 |> ignore

let logout (matrix_client: Matrix.client ref) =
 Matrix.logout !matrix_client
 |> ignore
