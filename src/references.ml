(* Helpers *)

let rec list_compress : 'a list -> 'a list =
  fun xs ->
    match xs with
      | a :: b :: rest ->
          if a = b then
            list_compress (b :: rest)
          else
            a :: list_compress (b :: rest)

      | _ ->
          xs

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

(* References *)

type ('i, 'o) reference =
  { function_name : string
  ; k_max : int
  ; d_in : 'i Denotation.t
  ; d_out : 'o Denotation.t
  ; input : 'i Sample2.gen
  ; base_case : 'i Sample2.gen option
  ; poly_args : Smyth.Lang.typ list
  ; func : 'i -> 'o
  }

type 'a reference_projection =
  { proj : 'i 'o . ('i, 'o) reference -> 'a
  }

let all : 'a reference_projection -> (string * 'a) list =
  fun { proj } ->
    [ ( "bool_band"
      , proj
          { function_name = "and"
          ; k_max = 4
          ; d_in = Denotation.args2 Denotation.bool Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.pair Sample2.bool Sample2.bool
          ; base_case = None
          ; poly_args = []
          ; func =
              let f : bool * bool -> bool =
                fun (x, y) ->
                  x && y
              in
              f
          }
      )
    ; ( "bool_bor"
      , proj
          { function_name = "or"
          ; k_max = 4
          ; d_in = Denotation.args2 Denotation.bool Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.pair Sample2.bool Sample2.bool
          ; base_case = None
          ; poly_args = []
          ; func =
              let f : bool * bool -> bool =
                fun (x, y) ->
                  x || y
              in
              f
          }
      )
    ; ( "bool_impl"
      , proj
          { function_name = "impl"
          ; k_max = 4
          ; d_in = Denotation.args2 Denotation.bool Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.pair Sample2.bool Sample2.bool
          ; base_case = None
          ; poly_args = []
          ; func =
              let f : bool * bool -> bool =
                fun (x, y) ->
                  (not x) || y
              in
              f
          }
      )
    ; ( "bool_neg"
      , proj
          { function_name = "neg"
          ; k_max = 2
          ; d_in = Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.bool
          ; base_case = None
          ; poly_args = []
          ; func =
              let f : bool -> bool =
                fun x ->
                  not x
              in
              f
          }
      )
    ; ( "bool_xor"
      , proj
          { function_name = "xor"
          ; k_max = 4
          ; d_in = Denotation.args2 Denotation.bool Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.pair Sample2.bool Sample2.bool
          ; base_case = None
          ; poly_args = []
          ; func =
              let f : bool * bool -> bool =
                fun (x, y) ->
                  x <> y
              in
              f
          }
      )
    ; ( "list_append"
      , proj
          { function_name = "append"
          ; k_max = 20
          ; d_in =
              Denotation.args2
                (Denotation.list Denotation.int)
                (Denotation.list Denotation.int)
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat_list
          ; base_case = Some (Sample2.constant ([], []))
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int list * int list -> int list =
                fun (xs, ys) ->
                  xs @ ys
              in
              f
          }
      )
    ; ( "list_compress"
      , proj
          { function_name = "compress"
          ; k_max = 20
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int list -> int list =
                fun xs ->
                  list_compress xs
              in
              f
          }
      )
    ; ( "list_concat"
      , proj
          { function_name = "concat"
          ; k_max = 20
          ; d_in = Denotation.nested_list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nested_nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int list list -> int list =
                fun xss ->
                  List.concat xss
              in
              f
          }
      )
    ; ( "list_drop"
      , proj
          { function_name = "listDrop"
          ; k_max = 20
          ; d_in =
              Denotation.args2 (Denotation.list Denotation.int) Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat
          ; base_case = Some (Sample2.constant ([], 0))
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int list * int -> int list =
                fun (xs, n) ->
                  List2.drop n xs
              in
              f
          }
      )
    ; ( "list_even_parity"
      , proj
          { function_name = "evenParity"
          ; k_max = 15
          ; d_in = Denotation.list Denotation.bool
          ; d_out = Denotation.bool
          ; input = Sample2.bool_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = []
          ; func =
              let f : bool list -> bool =
                fun bs ->
                  list_even_parity bs
              in
              f
          }
      )
    ; ( "list_filter"
      , proj
          { function_name = "listFilter"
          ; k_max = 20
          ; d_in =
              Denotation.args2
                Denotation.var
                (Denotation.list Denotation.int)
          ; d_out = Denotation.list Denotation.int
          ; input =
              Sample2.pair
                (Sample2.from ("isEven", ["isNonzero"]))
                Sample2.nat_list
          ; base_case = Some (Sample2.constant ("isEven", []))
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : string * int list -> int list =
                fun (fname, xs) ->
                  let pred =
                    match fname with
                      | "isEven" -> fun x -> x mod 2 = 0
                      | "isNonzero" -> fun x -> x <> 0
                      | _ -> failwith ("Unknown Myth built-in '" ^ fname ^ "'")
                  in
                  List.filter pred xs
              in
              f
          }
      )
    ; ( "list_fold"
      , proj
          { function_name = "listFold"
          ; k_max = 20
          ; d_in =
              Denotation.args3
                Denotation.var
                Denotation.int
                (Denotation.list Denotation.int)
          ; d_out = Denotation.int
          ; input =
              Sample2.triple
                (Sample2.from ("sum", ["countOdd"]))
                Sample2.nat
                Sample2.nat_list
          ; base_case = Some (Sample2.constant ("sum", 0, []))
          ; poly_args = [snd Denotation.int; snd Denotation.int]
          ; func =
              let f : string * int * int list -> int =
                fun (fname, acc, xs) ->
                  let folder =
                    match fname with
                      | "sum" ->
                          fun x y -> x + y
                      | "countOdd" ->
                          fun a x -> if x mod 2 = 1 then a + 1 else a
                      | _ ->
                          failwith ("Unknown Myth built-in '" ^ fname ^ "'")
                  in
                  List.fold_left folder acc xs
              in
              f
          }
      )
    ; ( "list_hd"
      , proj
          { function_name = "listHead"
          ; k_max = 10
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = []
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
      , proj
          { function_name = "listInc"
          ; k_max = 10
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = []
          ; func =
              let f : int list -> int list =
                fun xs ->
                  List.map ((+) 1) xs
              in
              f
          }
      )
    ; ( "list_last"
      , proj
          { function_name = "listLast"
          ; k_max = 20
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.opt Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = [snd Denotation.int]
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
      , proj
          { function_name = "listLength"
          ; k_max = 5
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int list -> int =
                fun xs ->
                  List.length xs
              in
              f
          }
      )
    ; ( "list_map"
      , proj
          { function_name = "listMap"
          ; k_max = 20
          ; d_in =
              Denotation.args2
                Denotation.var
                (Denotation.list Denotation.int)
          ; d_out = Denotation.list Denotation.int
          ; input =
              Sample2.pair
                (Sample2.from ("inc", ["zero"]))
                Sample2.nat_list
          ; base_case = Some (Sample2.constant ("inc", []))
          ; poly_args = [snd Denotation.int; snd Denotation.int]
          ; func =
              let f : string * int list -> int list =
                fun (fname, xs) ->
                  let mapper =
                    match fname with
                      | "inc" -> fun x -> x + 1
                      | "zero" -> fun _ -> 0
                      | _ -> failwith ("Unknown Myth built-in '" ^ fname ^ "'")
                  in
                  List.map mapper xs
              in
              f
          }
      )
    ; ( "list_nth"
      , proj
          { function_name = "listNth"
          ; k_max = 20
          ; d_in =
              Denotation.args2 (Denotation.list Denotation.int) Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat
          ; base_case = Some (Sample2.constant ([], 0))
          ; poly_args = []
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
      , proj
          { function_name = "listPairwiseSwap"
          ; k_max = 20
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = [snd Denotation.int]
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
      , proj
          { function_name = "listRevAppend"
          ; k_max = 15
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int list -> int list =
                fun xs ->
                  List.rev xs
              in
              f
          }
      )
    ; ( "list_rev_fold"
      , proj
          { function_name = "listRevFold"
          ; k_max = 15
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int list -> int list =
                fun xs ->
                  List.rev xs
              in
              f
          }
      )
    ; ( "list_rev_snoc"
      , proj
          { function_name = "listRevSnoc"
          ; k_max = 15
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int list -> int list =
                fun xs ->
                  List.rev xs
              in
              f
          }
      )
    ; ( "list_rev_tailcall"
      , proj
          { function_name = "listRevTailcall"
          ; k_max = 20
          ; d_in =
              Denotation.args2
                (Denotation.list Denotation.int)
                (Denotation.list Denotation.int)
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat_list
          ; base_case = Some (Sample2.constant ([], []))
          ; poly_args = [snd Denotation.int]
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
      , proj
          { function_name = "listSnoc"
          ; k_max = 20
          ; d_in =
              Denotation.args2 (Denotation.list Denotation.int) Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat
          ; base_case = Some (Sample2.constant ([], 0))
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int list * int -> int list =
                fun (xs, n) ->
                  xs @ [n]
              in
              f
          }
      )
    ; ( "list_sort_sorted_insert"
      , proj
          { function_name = "listSortSortedInsert"
          ; k_max = 20
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = []
          ; func =
              let f : int list -> int list =
                fun xs ->
                  List.sort_uniq Int.compare xs
              in
              f
          }
      )
    ; ( "list_sorted_insert"
      , proj
          { function_name = "listSortedInsert"
          ; k_max = 20
          ; d_in =
              Denotation.args2 (Denotation.list Denotation.int) Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat_list Sample2.nat
          ; base_case = Some (Sample2.constant ([], 0))
          ; poly_args = []
          ; func =
              let f : int list * int -> int list =
                fun (xs, n) ->
                  list_sorted_insert n xs
              in
              f
          }
      )
    ; ( "list_stutter"
      , proj
          { function_name = "listStutter"
          ; k_max = 10
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = [snd Denotation.int]
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
      , proj
          { function_name = "listSum"
          ; k_max = 10
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = []
          ; func =
              let f : int list -> int =
                fun xs ->
                  List2.sum xs
              in
              f
          }
      )
    ; ( "list_take"
      , proj
          { function_name = "listTake"
          ; k_max = 20
          ; d_in =
              Denotation.args2 Denotation.int (Denotation.list Denotation.int)
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.pair Sample2.nat Sample2.nat_list
          ; base_case = Some (Sample2.constant (0, []))
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int * int list -> int list =
                fun (n, xs) ->
                  List2.take n xs
              in
              f
          }
      )
    ; ( "list_tl"
      , proj
          { function_name = "listTail"
          ; k_max = 10
          ; d_in = Denotation.list Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_list
          ; base_case = Some (Sample2.constant [])
          ; poly_args = [snd Denotation.int]
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
      , proj
          { function_name = "isEven"
          ; k_max = 4
          ; d_in = Denotation.int
          ; d_out = Denotation.bool
          ; input = Sample2.nat
          ; base_case = Some (Sample2.constant 0)
          ; poly_args = []
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
      , proj
          { function_name = "natMax"
          ; k_max = 15
          ; d_in = Denotation.args2 Denotation.int Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.pair Sample2.nat Sample2.nat
          ; base_case = Some (Sample2.constant (0, 0))
          ; poly_args = []
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
      , proj
          { function_name = "natPred"
          ; k_max = 4
          ; d_in = Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.nat
          ; base_case = Some (Sample2.constant 0)
          ; poly_args = []
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
      , proj
          { function_name = "natAdd"
          ; k_max = 9
          ; d_in = Denotation.args2 Denotation.int Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.pair Sample2.nat Sample2.nat
          ; base_case = Some (Sample2.constant (0, 0))
          ; poly_args = []
          ; func =
              let f : int * int -> int =
                fun (x, y) ->
                  x + y
              in
              f
          }
      )
    ; ( "tree_binsert"
      , proj
          { function_name = "treeBInsert"
          ; k_max = 20
          ; d_in =
              Denotation.args2 Denotation.int (Denotation.tree Denotation.int)
          ; d_out = Denotation.tree Denotation.int
          ; input = Sample2.pair Sample2.nat Sample2.nat_tree
          ; base_case = Some (Sample2.constant (0, Tree2.Leaf))
          ; poly_args = []
          ; func =
              let f : int * int Tree2.t -> int Tree2.t =
                fun (y, tree) ->
                  Tree2.binsert y tree
              in
              f
          }
      )
    ; ( "tree_collect_leaves"
      , proj
          { function_name = "treeCollectLeaves"
          ; k_max = 20
          ; d_in = Denotation.tree Denotation.bool
          ; d_out = Denotation.list Denotation.bool
          ; input = Sample2.bool_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; poly_args = [snd Denotation.bool]
          ; func =
              let f : bool Tree2.t -> bool list =
                fun tree ->
                  Tree2.in_order tree
              in
              f
          }
      )
    ; ( "tree_count_leaves"
      , proj
          { function_name = "treeCountLeaves"
          ; k_max = 15
          ; d_in = Denotation.tree Denotation.bool
          ; d_out = Denotation.int
          ; input = Sample2.bool_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; poly_args = [snd Denotation.bool]
          ; func =
              let f : bool Tree2.t -> int =
                fun tree ->
                  Tree2.count_leaves tree
              in
              f
          }
      )
    ; ( "tree_count_nodes"
      , proj
          { function_name = "treeCountNodes"
          ; k_max = 15
          ; d_in = Denotation.tree Denotation.int
          ; d_out = Denotation.int
          ; input = Sample2.nat_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int Tree2.t -> int =
                fun tree ->
                  Tree2.count_nodes tree
              in
              f
          }
      )
    ; ( "tree_inorder"
      , proj
          { function_name = "treeInOrder"
          ; k_max = 15
          ; d_in = Denotation.tree Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int Tree2.t -> int list =
                fun tree ->
                  Tree2.in_order tree
              in
              f
          }
      )
    ; ( "tree_map"
      , proj
          { function_name = "treeMap"
          ; k_max = 20
          ; d_in =
              Denotation.args2
                Denotation.var
                (Denotation.tree Denotation.int)
          ; d_out = Denotation.tree Denotation.int
          ; input =
              Sample2.pair
                (Sample2.from ("div2", ["inc"]))
                Sample2.nat_tree
          ; base_case = Some (Sample2.constant ("div2", Tree2.Leaf))
          ; poly_args = [snd Denotation.int; snd Denotation.int]
          ; func =
              let f : string * int Tree2.t -> int Tree2.t =
                fun (fname, t) ->
                  let mapper =
                    match fname with
                      | "div2" -> fun x -> x / 2
                      | "inc" -> fun x -> x + 1
                      | _ -> failwith ("Unknown Myth built-in '" ^ fname ^ "'")
                  in
                  Tree2.map mapper t
              in
              f
          }
      )
    ; ( "tree_nodes_at_level"
      , proj
          { function_name = "treeNodesAtLevel"
          ; k_max = 20
          ; d_in =
              Denotation.args2 Denotation.int (Denotation.tree Denotation.bool)
          ; d_out = Denotation.int
          ; input = Sample2.pair Sample2.nat Sample2.bool_tree
          ; base_case = Some (Sample2.constant (0, Tree2.Leaf))
          ; poly_args = []
          ; func =
              let f : int * bool Tree2.t -> int =
                fun (level, tree) ->
                  Tree2.count_nodes_at_level level tree
              in
              f
          }
      )
    ; ( "tree_postorder"
      , proj
          { function_name = "treePostorder"
          ; k_max = 20
          ; d_in = Denotation.tree Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; poly_args = []
          ; func =
              let f : int Tree2.t -> int list =
                fun tree ->
                  Tree2.post_order tree
              in
              f
          }
      )
    ; ( "tree_preorder"
      , proj
          { function_name = "treePreorder"
          ; k_max = 15
          ; d_in = Denotation.tree Denotation.int
          ; d_out = Denotation.list Denotation.int
          ; input = Sample2.nat_tree
          ; base_case = Some (Sample2.constant Tree2.Leaf)
          ; poly_args = [snd Denotation.int]
          ; func =
              let f : int Tree2.t -> int list =
                fun tree ->
                  Tree2.pre_order tree
              in
              f
          }
      )
    ]
