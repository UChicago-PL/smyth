(** Type-and-example-directed refinement, as defined in {b Figure 9} of the
    ICFP 2020 paper. *)

open Lang

val refine :
  hole_ctx
    -> datatype_ctx
    -> synthesis_goal
    -> (exp * fill_goal list) option
    (** [refine delta sigma goal] splits the synthesis goal [goal] into subgoals
        based on type-and-example-directed refinement.

        Type-and-example-directed refinement is deterministic but may fail;
        hence, this function returns an {!option}. *)

val refine_app :
  hole_ctx
    -> datatype_ctx
    -> hole_filling
    -> synthesis_goal
    -> (exp * fill_goal list) Nondet.t
(** [refine_app delta sigma hf goal] transforms the synthesis goal [goal] into a
    helper function subgoal that is called on randomly generated values in
    scope. *)
