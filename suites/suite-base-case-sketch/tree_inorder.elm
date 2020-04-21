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
      Cons (get_2_1 p, append (get_2_2 p) l2)

treeInOrder : NatTree -> NatList
treeInOrder xss =
  case xss of
    Leaf _ ->
      Nil ()

    Node node ->
      ??
