(** Example helpers. *)

open Lang

val from_value : value -> example
(** "Upcasts" a simple value to an example. *)

val to_value : example -> value option
(** "Downcasts" an example to a simple value. *)
