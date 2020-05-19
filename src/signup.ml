type model =
  { matrix_client : Matrix.client ref
  ; username : string
  ; password : string
  }

let init matrix_client = { matrix_client; username = ""; password = "" }

type msg =
  | GoTo of Router.route
  | SaveUserName of string
  | SavePassword of string
  | Register
  | Registered of (Matrix.login_response, string) Tea.Result.t
  | ListInfo of (unit list, string) Tea.Result.t
[@@bs.deriving { accessors }]

let msg_to_string = function
  | SaveUserName _msg ->
      "save username"
  | SavePassword _msg ->
      "save password"
  | Register ->
      "register"
  | Registered _msg ->
      "registered" (*CreateGroup.msg_to_string msg*)
  | GoTo _msg ->
      "goto"
  | ListInfo _msg ->
      "list info"


(* let result promise msg = *)
(*   let open Vdom in *)
(*   Tea_cmd.call (function callbacks -> *)
(*       let enq result = *)
(*         !callbacks.enqueue (msg result) *)
(*       in *)
(*       let _ = promise *)
(*               |> Js.Promise.then_ (function res -> *)
(*                   let resolve = enq (Tea_result.Ok res) in *)
(*                   Js.Promise.resolve resolve *)
(*                 ) *)
(*               |> Js.Promise.catch (function err -> *)
(*                   let err_to_string err = *)
(*                     {j|$err|j} in *)
(*                   let reject = enq (Tea_result.Error (err_to_string err)) in *)
(*                   Js.Promise.resolve reject *)
(*                 ) *)
(*       in *)
(*       () *)
(*     ) *)

exception RegisterError

let register_cmd model =
  Matrix.register !(model.matrix_client) model.username model.password None None
  |> Js.Promise.catch (function _err ->
         Js.log [%raw {|_err|}] ;
         ( match [%raw {|_err.httpStatus|}] with
         | 401 ->
             let auth =
               [%bs.obj
                 { session = [%raw {|_err.data.session|}]
                 ; _type = "m.login.dummy"
                 }]
             in
             Matrix.register
               !(model.matrix_client)
               model.username
               model.password
               None
               (Some auth)
         | _ ->
             Js.Promise.reject RegisterError )
         (* |> *)
         (* Js.Promise.resolve *))
  |. Tea_promise.result registered


let save_cmd client =
  [ Tea.Ex.LocalStorage.setItem "access_token" (client##getAccessToken ())
  ; Tea.Ex.LocalStorage.setItem "matrix_id" client##credentials##userId
  ]
  |> Tea_task.sequence
  |> Tea_task.attempt listInfo


let update model = function
  | SaveUserName username ->
      ({ model with username }, Tea.Cmd.none)
  | SavePassword password ->
      ({ model with password }, Tea.Cmd.none)
  | Register ->
      (model, register_cmd model)
  | Registered (Tea.Result.Ok res) ->
      let () = Js.log res in
      model.matrix_client :=
        Matrix.new_client_params res##user_id res##access_token ;
      let () = Matrix.start_client !(model.matrix_client) in
      (model, Tea.Cmd.msg (GoTo Index))
      (*save_cmd !(model.matrix_client)*)
  | Registered (Tea.Result.Error err) ->
      let () = Js.log ("register failed: " ^ err) in
      (model, Tea.Cmd.none)
  | ListInfo (Tea.Result.Ok res) ->
      let () = Js.log res in
      (model, Tea.Cmd.none)
  | ListInfo (Tea.Result.Error err) ->
      let () = Js.log err in
      (model, Tea.Cmd.none)
  | GoTo _ ->
      (* this should never match *)
      (model, Tea.Cmd.none)


let view model =
  let open Tea.Html in
  form
    ~unique:"signup"
    [ Tea.Html2.Events.onSubmit register ]
    [ fieldset
        []
        [ label [ for' "username-field" ] [ text "Username" ]
        ; input'
            [ type' "text"; id "username-field"; onInput saveUserName ]
            [ text model.username ]
        ; label [ for' "password-field" ] [ text "Password" ]
        ; input'
            [ type' "password"; id "password-field"; onInput savePassword ]
            [ text model.password ]
        ; button [ type' "submit" ] [ text "Register" ]
        ]
    ]
