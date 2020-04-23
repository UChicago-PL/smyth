(* All timing units are in seconds. *)

let version : string =
  "0.1.0"

let debug_mode : bool =
  false

type ranking_method =
  | Size

let ranking_method =
  Size

(* None = infinity *)
let max_solution_count : int option =
  Some 30

let uneval_case_budget : int =
  10

let max_total_time : float =
  120.0

let max_eval_time : float =
  0.1

let max_guess_time : float =
  0.25

let initial_fuel : int =
  2500

let log_info : bool =
  true

let log_warn : bool =
  true
