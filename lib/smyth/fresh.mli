open Lang

(* Warning: this module uses mutation! *)

val unused : hole_name
val set_largest_hole : hole_name -> unit
val gen_hole : unit -> hole_name
