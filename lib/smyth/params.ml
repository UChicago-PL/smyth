(* All timing units are in seconds. *)

let version : string =
  "0.1.0"

let debug_mode : bool ref =
  ref false

type ranking_method =
  | Size

let ranking_method : ranking_method ref =
  ref Size

(* None = infinity *)
let max_solution_count : int option ref =
  ref (Some 30)

let uneval_case_budget : int ref =
  ref 10

let max_total_time : float ref =
  ref 20.0

let max_eval_time : float ref =
  ref 0.1

let max_guess_time : float ref =
  ref 0.25

let initial_fuel : int ref =
  ref 100

let log_info : bool ref =
  ref true

let log_warn : bool ref =
  ref true
