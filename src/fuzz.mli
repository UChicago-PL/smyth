open Smyth
open References

val experiment_proj :
  int -> (unit -> (Lang.exp * Lang.exp) list list list) reference_projection

val specification_proj :
  string reference_projection
