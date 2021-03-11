(** Synthesis and system parameters.

    Many of these options are also configurable with command-line flags.

    {b Note:} all timing units are in seconds. *)

let version : string =
  "0.1.0"
(** The overall version of the system. *)

let debug_mode : bool ref =
  ref false
(** Whether or not debugging should be enabled. *)

(** The available methods for ranking synthesis solutions. *)
type ranking_method =
  | Size (* Rank by AST size *)

let ranking_method : ranking_method ref =
  ref Size
(** The method to rank synthesis solutions. *)

let max_solution_count : int option ref =
  ref (Some 40)
(** The maximum synthesis solution count. [None] indicates no bound/infinity. *)

let uneval_case_budget : int ref =
  ref 10
(** The unevaluation case budget; sets a limit to the number of times U-Case is
    allowed to be called. *)

let uneval_limiter : int ref =
  ref 10
(** The unevluation limiter; immediately cuts off any unevaluation path that
    exceeds a certain number of nondeterministic possibilities (thereby
    eliminating pathological search paths that are unlikely to succeed). *)

let max_total_time : float ref =
  ref 20.0
(** The total time a single synthesis task is allowed to use. *)

let max_eval_time : float ref =
  ref 0.1
(** The time a single call to evaluation is allowed to use. *)

let max_guess_time : float ref =
  ref 0.25
(** The time a single call to Guess is allowed to use. *)

let initial_fuel : int ref =
  ref 100
(** The initial fuel count for evaluation and resumption. *)

let log_info : bool ref =
  ref true
(** Whether or not to enable info-level logging. *)

let log_warn : bool ref =
  ref true
(** Whether or not to enable warn-level logging. *)
