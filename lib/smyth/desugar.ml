open Lang

let lett : string -> exp -> exp -> exp =
  fun name binding body ->
    EApp (false, EFix (Some name, PVar name, body), binding)

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
