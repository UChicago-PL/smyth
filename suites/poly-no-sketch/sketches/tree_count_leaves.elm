type Boolean
  = F ()
  | T ()

type Tree a
  = Leaf ()
  | Node (Tree a, a, Tree a)

type Nat
  = Z ()
  | S Nat

sum : Nat -> Nat -> Nat
sum n1 n2 =
  case n1 of
    Z _ -> n2
    S m -> S (sum m n2)

treeCountLeaves : forall a . Tree a -> Nat
treeCountLeaves <a> tree =
  ??
