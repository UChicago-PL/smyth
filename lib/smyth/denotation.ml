open Lang

type 'a t =
  'a -> exp

let bool : bool t =
  fun b ->
    if b then
      ECtor ("T", ETuple [])
    else
      ECtor ("F", ETuple [])

let int : int t =
  Desugar.nat

let opt : 'a t -> 'a option t =
  fun da x_opt ->
    match x_opt with
      | None ->
          ECtor ("None", ETuple [])

      | Some x ->
          ECtor ("Some", da x)

let generic_list : string -> string -> 'a t -> 'a list t =
  fun cons nil da xs ->
    List.fold_right
      ( fun x acc ->
          ECtor (cons, ETuple [da x; acc])
      )
      xs
      (ECtor (nil, ETuple []))

let list : 'a t -> 'a list t =
  fun da ->
    generic_list "Cons" "Nil" da

let nested_list : 'a t -> 'a list list t =
  fun da ->
    generic_list "LCons" "LNil" (list da)

let rec tree : 'a t -> 'a Tree2.t t =
  fun da t ->
    match t with
      | Tree2.Leaf ->
          ECtor ("Leaf", ETuple [])

      | Tree2.Node (left, x, right) ->
          ECtor
            ( "Node"
            , ETuple
                [ tree da left
                ; da x
                ; tree da right
                ]
            )

let args2 : 'a1 t -> 'a2 t -> ('a1 * 'a2) t =
  fun da1 da2 (x1, x2) ->
    ETuple [da1 x1; da2 x2]
