
let logout (model: Chat.model) =
  let _  = Matrix.logout !(model.matrix_client) in
  model
