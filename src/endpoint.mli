open Smyth

type error =
  | ParseError of (Parse.context, Parse.problem) Bark.dead_end list
  | TypeError of (Lang.exp * Type.error)
  | EvalError of string

type 'a response =
  ('a, error) result

val solve :
  sketch:string ->
  (Lang.hole_name * Lang.exp) list list response

val test :
  definitions:string ->
  complete_assertions:string ->
  partial_assertions:string ->
  bool response
