type Nat
  = Z ()
  | S Nat

type Tree a
  = Leaf ()
  | Node (Tree a, a, Tree a)

sum : Nat -> Nat -> Nat
sum n1 n2 =
  case n1 of
    Z _ -> n2
    S m -> S (sum m n2)

treeCountNodes : forall a . Tree a -> Nat
treeCountNodes <a> tree =
  case tree of
    Leaf _ ->
      Z ()

    Node node ->
      ??
