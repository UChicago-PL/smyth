open Lang

let lett : string -> exp -> exp -> exp =
  fun name binding body ->
    EApp (false, EFix (Some name, name, body), binding)

type program =
  { datatypes : datatype_ctx
  ; definitions : (string * typ * exp) list
  ; assertions : (exp * exp) list
  ; main_opt : exp option
  }

let program : program -> exp * datatype_ctx =
  fun { datatypes; definitions; assertions; main_opt } ->
    ( List.fold_right
        ( fun (name, the_typ, the_exp) ->
            lett name (ETypeAnnotation (the_exp, the_typ))
        )
        definitions
        ( List.fold_right
            ( fun (e1, e2) ->
                lett "_" (EAssert (e1, e2))
            )
            assertions
            ( Option2.with_default (ETuple [])
                main_opt
            )
        )
    , datatypes
    )
