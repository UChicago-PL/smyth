open Smyth

(* References *)

type ('a, 'b) reference =
  { function_name : string
  ; k_max : int
  ; d_in : 'a Denotation.t
  ; d_out : 'b Denotation.t
  ; input : 'a Sample2.gen
  ; base_case : 'a Sample2.gen option
  ; func : 'a -> 'b
  }

(* Helpers *)

let rec list_even_parity : bool list -> bool =
  fun bs ->
    match bs with
      | [] ->
          true

      | head :: tail ->
          if head then
            not (list_even_parity tail)
          else
            list_even_parity tail

let rec list_pairwise_swap : 'a list -> 'a list option =
  fun xs ->
    match xs with
      | [] ->
          Some []

      | [_] ->
          None

      | x1 :: x2 :: tail ->
          Option.map
            (fun flipped -> x2 :: x1 :: flipped)
            (list_pairwise_swap tail)

let rec list_sorted_insert : 'a -> 'a list -> 'a list =
  fun y xs ->
    match xs with
      | [] ->
          [y]

      | head :: tail ->
          if y < head then
            y :: xs
          else if y = head then
            xs
          else
            head :: (list_sorted_insert y tail)

(* Benchmarks *)

let make_benchmark :
 int -> ('a, 'b) reference -> unit -> (Lang.exp * Lang.exp) list list list =
  fun n { function_name; k_max; d_in; d_out; input; base_case; func } () ->
    List.map
      ( fun k ->
          List.map
            ( List.map
                ( fun (input, output) ->
                  let args =
                    match d_in input with
                      | Lang.ECtor ("args", Lang.ETuple args) ->
                          args

                      | arg ->
                          [arg]
                    in
                    ( Desugar.app (Lang.EVar function_name) args
                    , d_out output
                    )
                )
            )
            ( Sample2.io_trial n k func input base_case
            )
      )
      ( List2.range ~low:1 ~high:k_max
      )

let benchmarks :
 int -> (string * (unit -> (Lang.exp * Lang.exp) list list list)) list =
  fun trial_count ->
    [ ( "bool_band"
      , make_benchmark trial_count
          { function_name = "and"
          ; k_max = 4
          ; d_in = Denotation.args2 Denotation.bool Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.pair Sample2.bool Sample2.bool
          ; base_case = None
          ; func =
              let f : bool * bool -> bool =
                fun (x, y) ->
                  x && y
              in
              f
          }
      )
    ; ( "bool_bor"
      , make_benchmark trial_count
          { function_name = "or"
          ; k_max = 4
          ; d_in = Denotation.args2 Denotation.bool Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.pair Sample2.bool Sample2.bool
          ; base_case = None
          ; func =
              let f : bool * bool -> bool =
                fun (x, y) ->
                  x || y
              in
              f
          }
      )
    ; ( "bool_impl"
      , make_benchmark trial_count
          { function_name = "impl"
          ; k_max = 4
          ; d_in = Denotation.args2 Denotation.bool Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.pair Sample2.bool Sample2.bool
          ; base_case = None
          ; func =
              let f : bool * bool -> bool =
                fun (x, y) ->
                  (not x) || y
              in
              f
          }
      )
    ; ( "bool_neg"
      , make_benchmark trial_count
          { function_name = "neg"
          ; k_max = 2
          ; d_in = Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.bool
          ; base_case = None
          ; func =
              let f : bool -> bool =
                fun x ->
                  not x
              in
              f
          }
      )
    ; ( "bool_xor"
      , make_benchmark trial_count
          { function_name = "xor"
          ; k_max = 4
          ; d_in = Denotation.args2 Denotation.bool Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.pair Sample2.bool Sample2.bool
          ; base_case = None
          ; func =
              let f : bool * bool -> bool =
                fun (x, y) ->
                  x <> y
              in
              f
          }
      )
    ; ( "list_append"
      , make_benchmark trial_count
          { function_name = "append"
          ; k_max = 20
          ; d_in =
              Denotation.args2
                (Denotation.list Denotation.int)
                (Denotation.list Denotation.int)
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat_list
          ; base_case = Some (Sample2.constant ([], []))
          ; func =
              let f : int list * int list -> int list =
                fun (xs, ys) ->
                  xs @ ys
              in
              f
          }
      )
    ; ( "list_concat"
      , make_benchmark trial_count
          { function_name = "concat"
          ; k_max = 20
          ; d_in = Denotation.nested_list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nested_nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list list -> int list =
                fun xss ->
                  List.concat xss
              in
              f
          }
      )
    ; ( "list_drop"
      , make_benchmark trial_count
          { function_name = "listDrop"
          ; k_max = 40
          ; d_in =
              Denotation.args2 (Denotation.list Denotation.int) Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat
          ; base_case = Some (Sample2.constant ([], 0))
          ; func =
              let f : int list * int -> int list =
                fun (xs, n) ->
                  List2.drop n xs
              in
              f
          }
      )
    ; ( "list_even_parity"
      , make_benchmark trial_count
          { function_name = "evenParity"
          ; k_max = 15
          ; d_in = Denotation.list Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.bool_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : bool list -> bool =
                fun bs ->
                  list_even_parity bs
              in
              f
          }
      )
    ; ( "list_hd"
      , make_benchmark trial_count
          { function_name = "listHead"
          ; k_max = 10
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list -> int =
                fun xs ->
                  match xs with
                    | [] ->
                        0

                    | head :: _ ->
                        head
              in
              f
          }
      )
    ; ( "list_inc"
      , make_benchmark trial_count
          { function_name = "listInc"
          ; k_max = 10
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list -> int list =
                fun xs ->
                  List.map ((+) 1) xs
              in
              f
          }
      )
    ; ( "list_last"
      , make_benchmark trial_count
          { function_name = "listLast"
          ; k_max = 20
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.opt Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let rec f : int list -> int option =
                fun xs ->
                  match xs with
                    | [] ->
                        None

                    | [x] ->
                        Some x

                    | _ :: tail ->
                        f tail
              in
              f
          }
      )
    ; ( "list_length"
      , make_benchmark trial_count
          { function_name = "listLength"
          ; k_max = 5
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list -> int =
                fun xs ->
                  List.length xs
              in
              f
          }
      )
    ; ( "list_nth"
      , make_benchmark trial_count
          { function_name = "listNth"
          ; k_max = 40
          ; d_in =
              Denotation.args2 (Denotation.list Denotation.int) Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat
          ; base_case = Some (Sample2.constant ([], 0))
          ; func =
              let rec f : int list * int -> int =
                fun (xs, n) ->
                  match xs with
                    | [] ->
                        0

                    | head :: tail ->
                        if n = 0 then
                          head
                        else
                          f (tail, n - 1)
              in
              f
          }
      )
    ; ( "list_pairwise_swap"
      , make_benchmark trial_count
          { function_name = "listPairwiseSwap"
          ; k_max = 20
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list -> int list =
                fun xs ->
                  match list_pairwise_swap xs with
                    | None ->
                        []

                    | Some flipped ->
                        flipped
              in
              f
          }
      )
    ; ( "list_rev_append"
      , make_benchmark trial_count
          { function_name = "listRevAppend"
          ; k_max = 15
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list -> int list =
                fun xs ->
                  List.rev xs
              in
              f
          }
      )
    ; ( "list_rev_fold"
      , make_benchmark trial_count
          { function_name = "listRevFold"
          ; k_max = 15
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list -> int list =
                fun xs ->
                  List.rev xs
              in
              f
          }
      )
    ; ( "list_rev_snoc"
      , make_benchmark trial_count
          { function_name = "listRevSnoc"
          ; k_max = 15
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list -> int list =
                fun xs ->
                  List.rev xs
              in
              f
          }
      )
    ; ( "list_rev_tailcall"
      , make_benchmark trial_count
          { function_name = "listRevTailcall"
          ; k_max = 20
          ; d_in =
              Denotation.args2
                (Denotation.list Denotation.int)
                (Denotation.list Denotation.int)
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat_list
          ; base_case = Some (Sample2.constant ([], []))
          ; func =
              let rec f : int list * int list -> int list =
                fun (xs, acc) ->
                  match xs with
                    | [] ->
                        acc

                    | head :: tail ->
                        f (tail, head :: acc)
              in
              f
          }
      )
    ; ( "list_snoc"
      , make_benchmark trial_count
          { function_name = "listSnoc"
          ; k_max = 20
          ; d_in =
              Denotation.args2 (Denotation.list Denotation.int) Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat
          ; base_case = Some (Sample2.constant ([], 0))
          ; func =
              let f : int list * int -> int list =
                fun (xs, n) ->
                  xs @ [n]
              in
              f
          }
      )
    ; ( "list_sort_sorted_insert"
      , make_benchmark trial_count
          { function_name = "listSortSortedInsert"
          ; k_max = 20
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list -> int list =
                fun xs ->
                  List.sort_uniq Int.compare xs
              in
              f
          }
      )
    ; ( "list_sorted_insert"
      , make_benchmark trial_count
          { function_name = "listSortedInsert"
          ; k_max = 40
          ; d_in =
              Denotation.args2 (Denotation.list Denotation.int) Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat
          ; base_case = Some (Sample2.constant ([], 0))
          ; func =
              let f : int list * int -> int list =
                fun (xs, n) ->
                  list_sorted_insert n xs
              in
              f
          }
      )
    ; ( "list_stutter"
      , make_benchmark trial_count
          { function_name = "listStutter"
          ; k_max = 10
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let rec f : int list -> int list =
                fun xs ->
                  match xs with
                    | [] ->
                        []

                    | y :: ys ->
                        y :: y :: f ys
              in
              f
          }
      )
    ; ( "list_sum"
      , make_benchmark trial_count
          { function_name = "listSum"
          ; k_max = 10
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list -> int =
                fun xs ->
                  List2.sum xs
              in
              f
          }
      )
    ; ( "list_take"
      , make_benchmark trial_count
          { function_name = "listTake"
          ; k_max = 40
          ; d_in =
              Denotation.args2 Denotation.int (Denotation.list Denotation.int)
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat Sample2.nat_list
          ; base_case = Some (Sample2.constant (0, []))
          ; func =
              let f : int * int list -> int list =
                fun (n, xs) ->
                  List2.take n xs
              in
              f
          }
      )
    ; ( "list_tl"
      , make_benchmark trial_count
          { function_name = "listTail"
          ; k_max = 10
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; func =
              let f : int list -> int list =
                fun xs ->
                  match xs with
                    | [] ->
                        []

                    | _ :: tail ->
                        tail
              in
              f
          }
      )
    ; ( "nat_iseven"
      , make_benchmark trial_count
          { function_name = "isEven"
          ; k_max = 4
          ; d_in = Denotation.int
          ; d_out = Denotation.bool
          ; input = Sample2.nat
          ; base_case = Some (Sample2.constant 0)
          ; func =
              let rec f : int -> bool =
                fun x ->
                  if x = 0 then
                    true
                  else if x = 1 then
                    false
                  else
                    f (x - 2)
              in
              f
          }
      )
    ; ( "nat_max"
      , make_benchmark trial_count
          { function_name = "natMax"
          ; k_max = 15
          ; d_in = Denotation.args2 Denotation.int Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.pair Sample2.nat Sample2.nat
          ; base_case = Some (Sample2.constant (0, 0))
          ; func =
              let f : int * int -> int =
                fun (x, y) ->
                  if x >= y then
                    x
                  else
                    y
              in
              f
          }
      )
    ; ( "nat_pred"
      , make_benchmark trial_count
          { function_name = "natPred"
          ; k_max = 4
          ; d_in = Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.nat
          ; base_case = Some (Sample2.constant 0)
          ; func =
              let f : int -> int =
                fun x ->
                  if x = 0 then
                    0
                  else
                    x - 1
              in
              f
          }
      )
    ; ( "nat_add"
      , make_benchmark trial_count
          { function_name = "natAdd"
          ; k_max = 9
          ; d_in = Denotation.args2 Denotation.int Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.pair Sample2.nat Sample2.nat
          ; base_case = Some (Sample2.constant (0, 0))
          ; func =
              let f : int * int -> int =
                fun (x, y) ->
                  x + y
              in
              f
          }
      )
    ; ( "tree_binsert"
      , make_benchmark trial_count
          { function_name = "treeBInsert"
          ; k_max = 40
          ; d_in =
              Denotation.args2 Denotation.int (Denotation.tree Denotation.int)
          ; d_out = Denotation.tree Denotation.int
          ; input = Sample2.pair Sample2.nat Sample2.nat_tree
          ; base_case = Some (Sample2.constant (0, Tree2.Leaf))
          ; func =
              let f : int * int Tree2.t -> int Tree2.t =
                fun (y, tree) ->
                  Tree2.binsert y tree
              in
              f
          }
      )
    ; ( "tree_collect_leaves"
      , make_benchmark trial_count
          { function_name = "treeCollectLeaves"
          ; k_max = 20
          ; d_in = Denotation.tree Denotation.bool
          ; d_out = Denotation.list Denotation.bool
          ; input = Sample2.bool_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; func =
              let f : bool Tree2.t -> bool list =
                fun tree ->
                  Tree2.in_order tree
              in
              f
          }
      )
    ; ( "tree_count_leaves"
      , make_benchmark trial_count
          { function_name = "treeCountLeaves"
          ; k_max = 15
          ; d_in = Denotation.tree Denotation.bool
          ; d_out = Denotation.int
          ; input = Sample2.bool_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; func =
              let f : bool Tree2.t -> int =
                fun tree ->
                  Tree2.count_leaves tree
              in
              f
          }
      )
    ; ( "tree_count_nodes"
      , make_benchmark trial_count
          { function_name = "treeCountNodes"
          ; k_max = 15
          ; d_in = Denotation.tree Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.nat_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; func =
              let f : int Tree2.t -> int =
                fun tree ->
                  Tree2.count_nodes tree
              in
              f
          }
      )
    ; ( "tree_inorder"
      , make_benchmark trial_count
          { function_name = "treeInOrder"
          ; k_max = 15
          ; d_in = Denotation.tree Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; func =
              let f : int Tree2.t -> int list =
                fun tree ->
                  Tree2.in_order tree
              in
              f
          }
      )
    ; ( "tree_nodes_at_level"
      , make_benchmark trial_count
          { function_name = "treeNodesAtLevel"
          ; k_max = 20
          ; d_in =
              Denotation.args2 Denotation.int (Denotation.tree Denotation.bool)
          ; d_out = Denotation.int
          ; input = Sample2.pair Sample2.nat Sample2.bool_tree
          ; base_case = Some (Sample2.constant (0, Tree2.Leaf))
          ; func =
              let f : int * bool Tree2.t -> int =
                fun (level, tree) ->
                  Tree2.count_nodes_at_level level tree
              in
              f
          }
      )
    ; ( "tree_postorder"
      , make_benchmark trial_count
          { function_name = "treePostorder"
          ; k_max = 20
          ; d_in = Denotation.tree Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; func =
              let f : int Tree2.t -> int list =
                fun tree ->
                  Tree2.post_order tree
              in
              f
          }
      )
    ; ( "tree_preorder"
      , make_benchmark trial_count
          { function_name = "treePreorder"
          ; k_max = 15
          ; d_in = Denotation.tree Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; func =
              let f : int Tree2.t -> int list =
                fun tree ->
                  Tree2.pre_order tree
              in
              f
          }
      )
    ]
