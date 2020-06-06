type msg = GoTo of Router.route [@@bs.deriving { accessors }]

type model = { matrix_client : Matrix.client ref }

let init matrix_client = { matrix_client }

let update model = function GoTo _ -> (model, Tea.Cmd.none)

let statements room =
  (* let room_state = room##currentState in *)
  (* let statements_states = Matrix.StatementState.get room_state "pm.imago.group" None in *)
  let room_state = room##currentState in
  let statements_states =
    Matrix.StatementState.get room_state "pm.imago.groups.statement"
  in
  statements_states
  |> Tablecloth.Array.fold_left
       ~initial:Statements.empty
       ~f:(fun stm_state acc ->
         let property = stm_state##state_key in
         let objs = (stm_state##getContent ())##objects in
         Statements.set_statements
           acc
           property
           (Tablecloth.Array.map objs ~f:(fun item ->
                { Statements.label = item; description = ""; item })))


let view model room_id =
  let room = !(model.matrix_client)##getRoom room_id in
  let statements = statements room in
  let open Tea.Html in
  let obj_view _property (obj : Statements.obj) =
    div
      [ id "object-item" ]
      [ span [] [ text (obj.label ^ " (" ^ obj.description ^ ")") ] ]
  in
  let statement_view (property, objs) =
    div
      [ id "statement-item" ]
      [ div [ id "property-item" ] [ text property ]
      ; div
          [ id "objects-list" ]
          (Belt.Array.map objs (obj_view property) |> Belt.List.fromArray)
      ]
  in
  let statements_list =
    div
      [ id "statements-list" ]
      (Belt.Map.toList statements |. Belt.List.map statement_view)
  in
  let events_list = div [ id "events-list" ] [] in
  div ~unique:"group" ~key:room_id [] [ statements_list; events_list ]
