open Smyth

val benchmarks :
  int -> (string * (unit -> (Lang.exp * Lang.exp) list list list)) list
