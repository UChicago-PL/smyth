open Lang

let lett : string -> exp -> exp -> exp =
  fun name binding body ->
    EApp (false, EFix (Some name, name, body), binding)
