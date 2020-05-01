open Smyth

val trial_count : int

val benchmarks :
  (string * (unit -> (Lang.exp * Lang.exp) list list list)) list
