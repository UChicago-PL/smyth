open Lang

type param =
  | PatParam of pat
  | TypeParam of string

type arg =
  | ExpArg of exp
  | TypeArg of typ

val lett : typ -> string -> exp -> exp -> exp

val func_params : param list -> exp -> exp

val app : exp -> arg list -> exp

(* Precondition: input >= 0 *)
val nat : int -> exp

val listt : exp list -> typ list -> exp

type program =
  { datatypes : datatype_ctx
  ; definitions : (string * typ * exp) list
  ; assertions : (exp * exp) list
  ; main_opt : exp option
  }

val program : program -> exp * datatype_ctx
