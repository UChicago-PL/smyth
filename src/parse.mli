open Lang

type problem

type context

type 'a parser =
  (context, problem, 'a) Bark.parser

val exp : exp parser

val typ : typ parser

type program =
  { datatypes : datatype_ctx
  ; bindings : string * (typ * exp) list
  ; assertions : exp * exp list
  ; main : exp option
  }

val program : program parser
