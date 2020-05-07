type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

type NatTree
  = Leaf ()
  | Node (NatTree, Nat, NatTree)

div2 : Nat -> Nat
div2 n =
  case n of
    Z _ -> Z ()
    S m1 ->
      case m1 of
        Z _ -> Z ()
        S m2 -> S (div2 m2)

inc : Nat -> Nat
inc n =
  S n

treeMap : (Nat -> Nat) -> NatTree -> NatTree
treeMap f =
  let
    fixTreeMap : NatTree -> NatTree
    fixTreeMap tree =
      case tree of
        Leaf _ ->
          Leaf ()

        Node node ->
          ??
  in
    fixTreeMap
