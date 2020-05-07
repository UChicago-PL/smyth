type hole_name =
  int
  [@@deriving yojson]

module Hole_map =
  Map.Make
    ( struct
        type t = hole_name
        let compare = Int.compare end
    )

type 'a hole_map =
  'a Hole_map.t

type typ =
  | TArr of typ * typ
  | TTuple of typ list
  | TData of string * typ list
  | TForall of string * typ
  | TVar of string
  [@@deriving yojson]

type pat =
  | PVar of string
  | PTuple of pat list
  | PWildcard
  [@@deriving yojson]

type param =
  | PatParam of pat
  | TypeParam of string
  [@@deriving yojson]

type exp_arg =
  | EAExp of exp
  | EAType of typ
  [@@deriving yojson]

and exp =
  | EFix of string option * param * exp
  (* bool: special recursive call (used only for "recursive window" UI) *)
  | EApp of bool * exp * exp_arg
  | EVar of string
  | ETuple of exp list
  (* (n, i, arg) *)
  | EProj of int * int * exp
  | ECtor of string * typ list * exp
  | ECase of exp * (string * (pat * exp)) list
  | EHole of hole_name
  | EAssert of exp * exp
  | ETypeAnnotation of exp * typ
  [@@deriving yojson]

type res_arg =
  | RARes of res
  | RAType of typ
  [@@deriving yojson]

and res =
  (* Determinate results *)
  | RFix of env * (string option) * param * exp
  | RTuple of res list
  | RCtor of string * res
  (* Indeterminate results *)
  | RHole of env * hole_name
  | RApp of res * res_arg
  | RProj of int * int * res
  | RCase of env * res * (string * (pat * exp)) list
  | RCtorInverse of string * res
  [@@deriving yojson]

and env =
  (string * res) list * (string * typ) list
  [@@deriving yojson]

type bind_spec =
  | NoSpec
  | Rec of string
  | Arg of string
  | Dec of string
  [@@deriving yojson]

type type_binding =
  string * (typ * bind_spec)
  [@@deriving yojson]

type poly_binding =
  string
  [@@deriving yojson]

type type_ctx =
  type_binding list * poly_binding list
  [@@deriving yojson]

type datatype_ctx =
  (string * (string list * (string * typ) list)) list
  [@@deriving yojson]

(* (hole name, (type context, type, function decrease requirement, match depth))
 *)
type hole_ctx =
  (hole_name * (type_ctx * typ * string option * int)) list
  [@@deriving yojson]

type value =
  | VTuple of value list
  | VCtor of string * value
  [@@deriving yojson]

type example =
  | ExTuple of example list
  | ExCtor of string * example
  | ExInputOutput of value * example
  | ExTop
  [@@deriving yojson]

type world =
  env * example

type worlds =
  world list

type hole_filling =
  exp hole_map

type unsolved_constraints =
  worlds hole_map

type constraints =
  hole_filling * unsolved_constraints

type resumption_assertion =
  res * value
  [@@deriving yojson]

type resumption_assertions =
  resumption_assertion list
  [@@deriving yojson]

type gen_goal =
  type_ctx * typ * string option

type synthesis_goal =
  gen_goal * worlds

type fill_goal =
  hole_name * synthesis_goal

type synthesis_params =
  { max_scrutinee_size : int
  ; max_match_depth : int
  ; max_term_size : int
  }
