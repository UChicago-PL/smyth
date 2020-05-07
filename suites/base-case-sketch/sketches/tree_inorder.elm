type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

type NatTree
  = Leaf ()
  | Node (NatTree, Nat, NatTree)

append : NatList -> NatList -> NatList
append l1 l2 =
  case l1 of
    Nil _ ->
      l2
    Cons p ->
      Cons (#2.1 p, append (#2.2 p) l2)

treeInOrder : NatTree -> NatList
treeInOrder xss =
  case xss of
    Leaf _ ->
      Nil ()

    Node node ->
      ??
