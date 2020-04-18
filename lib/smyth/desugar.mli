open Lang

val lett : string -> exp -> exp -> exp

val func_args : pat list -> exp -> exp

val app : exp -> exp list -> exp

type program =
  { datatypes : datatype_ctx
  ; definitions : (string * typ * exp) list
  ; assertions : (exp * exp) list
  ; main_opt : exp option
  }

val program : program -> exp * datatype_ctx
