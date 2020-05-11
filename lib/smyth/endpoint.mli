type error =
  | ParseError of (Parse.context, Parse.problem) Bark.dead_end list
  | TypeError of (Lang.exp * Type.error)
  | EvalError of string
  | TimedOut of float
  | NoSolutions
  | PartialNotSubsetFull

type 'a response =
  ('a, error) result

(* Solve *)

type solve_result =
  { hole_fillings : (Lang.hole_name * Lang.exp) list list
  ; time_taken : float
  }

val solve : sketch:string -> solve_result response

(* Test *)

type test_result =
  { time_taken : float
  ; specification_assertion_count : int
  ; assertion_count : int
  ; top_success : bool
  ; top_recursive_success : bool
  }

val test :
  specification:string ->
  sketch:string ->
  examples:string ->
  test_result response

val test_assertions :
  specification:string ->
  sketch:string ->
  assertions:((Lang.exp * Lang.exp) list) ->
  test_result response

(* Assertion Info *)

val assertion_info :
  specification:string ->
  assertions:string ->
  (bool * Lang.exp list * Lang.exp) list response
