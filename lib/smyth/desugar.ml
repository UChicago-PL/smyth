open Lang

let annotate_rec_name : string -> exp -> exp =
  fun rec_name exp ->
    match exp with
      | EFix (_, param, body) ->
          EFix (Some rec_name, param, body)

      | _ ->
          exp

let lett : (typ * typ) option -> string -> exp -> exp -> exp =
  fun type_info_opt name binding body ->
    let func_inner =
      EFix (None, PVar name, body)
    in
    let func =
      match type_info_opt with
        | Some (binding_typ, body_typ) ->
            ETypeAnnotation (func_inner, TArr (binding_typ, body_typ))

        | None ->
            func_inner
    in
    EApp (false, func, annotate_rec_name name binding)

let func_args : pat list -> exp -> exp =
  List.fold_right
    ( fun pat body ->
        EFix (None, pat, body)
    )

let app : exp -> exp list -> exp =
  List.fold_left
    ( fun acc arg ->
        EApp (false, acc, arg)
    )

(* Precondition: input >= 0 *)
let nat : int -> exp =
  let rec helper acc n =
    if n = 0 then
      acc
    else
      helper (ECtor ("S", acc)) (n - 1)
  in
  helper (ECtor ("Z", ETuple []))

let listt : exp list -> exp =
  fun es ->
    List.fold_right
      ( fun e acc ->
          ECtor ("Cons", ETuple [e; acc])
      )
      es
      (ECtor ("Nil", ETuple []))

type program =
  { datatypes : datatype_ctx
  ; definitions : (string * typ * exp) list
  ; assertions : (exp * exp) list
  ; main_opt : exp option
  }

let program : program -> exp * datatype_ctx =
  fun { datatypes; definitions; assertions; main_opt } ->
    ( Post_parse.exp
        ( List.fold_right
            ( fun (name, the_typ, the_exp) ->
                lett (Some (the_typ, TTuple [])) name the_exp
            )
            definitions
            ( List.fold_right
                ( fun (e1, e2) ->
                  lett (Some (TTuple [], TTuple [])) "_" (EAssert (e1, e2))
                )
                assertions
                ( Option2.with_default (ETuple [])
                    main_opt
                )
            )
        )
    , List.rev datatypes
    )
