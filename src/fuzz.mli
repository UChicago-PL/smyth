open Smyth
open References

val experiment_proj :
  poly:bool -> n:int ->
  (unit -> (Lang.exp * Lang.exp) list list list) reference_projection

val specification_proj :
  poly:bool -> string reference_projection
