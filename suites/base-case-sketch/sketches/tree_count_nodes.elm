type Nat
  = Z ()
  | S Nat

type NatTree
  = Leaf ()
  | Node (NatTree, Nat, NatTree)

sum : Nat -> Nat -> Nat
sum n1 n2 =
  case n1 of
    Z _ -> n2
    S m -> S (sum m n2)

treeCountNodes : NatTree -> Nat
treeCountNodes tree =
  case tree of
    Leaf _ ->
      Z ()

    Node node ->
      ??
