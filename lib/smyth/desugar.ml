open Lang

type param =
  | PatParam of pat
  | TypeParam of string

type arg =
  | ExpArg of exp
  | TypeArg of typ

let annotate_rec_name : string -> exp -> exp =
  fun rec_name exp ->
    match exp with
      | EFix (_, param, body) ->
          EFix (Some rec_name, param, body)

      | _ ->
          exp

let lett : typ -> string -> exp -> exp -> exp =
  fun the_typ name binding body ->
    EApp
      ( false
      , EFix (None, PVar name, body)
      , ETypeAnnotation
          ( annotate_rec_name name binding
          , the_typ
          )
      )

let func_params : param list -> exp -> exp =
  List.fold_right
    ( fun param body ->
        match param with
          | PatParam pat ->
              EFix (None, pat, body)

          | TypeParam type_param ->
              ETAbs (type_param, body)
    )

let app : exp -> arg list -> exp =
  List.fold_left
    ( fun acc arg ->
        match arg with
          | ExpArg exp ->
              EApp (false, acc, exp)

          | TypeArg typ ->
              ETApp (acc, typ)
    )

(* Precondition: input >= 0 *)
let nat : int -> exp =
  let rec helper acc n =
    if n = 0 then
      acc
    else
      helper (ECtor ("S", [], acc)) (n - 1)
  in
  helper (ECtor ("Z", [], ETuple []))

let listt : exp list -> exp =
  fun es ->
    List.fold_right
      ( fun e acc ->
          ECtor ("Cons", [], ETuple [e; acc])
      )
      es
      (ECtor ("Nil", [], ETuple []))

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
                lett the_typ name the_exp
            )
            definitions
            ( List.fold_right
                ( fun (e1, e2) ->
                  lett (TTuple []) "_" (EAssert (e1, e2))
                )
                assertions
                ( Option2.with_default (ETuple [])
                    main_opt
                )
            )
        )
    , List.rev datatypes
    )
