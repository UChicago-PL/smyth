open Lang

val syntactically_equal : pat -> pat -> bool
val bind : pat -> res -> env option
val bind_var_opt : string option -> res -> env
