(** "Ground truth" example satisfaction. *)

open Lang

val res : hole_filling -> res -> example -> bool
(** Example satisfaction as defined in {b Figure 5} of the ICFP 2020 paper. *)

val exp : hole_filling -> exp -> worlds -> bool
(** Example constraint satisfaction as defined in {b Figure 5} of the
    ICFP 2020 paper. *)
