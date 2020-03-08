
let logout (model: Chat.model) =
  Matrix.logout model.client;
  model
