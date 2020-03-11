
let logout (model: Chat.model) =
  let _  = Matrix.logout model.client in
  model
