type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

type Tree a
  = Leaf ()
  | Node (Tree a, a, Tree a)

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

treeMap : forall a . forall b . (a -> b) -> Tree a -> Tree b
treeMap <a, b> f =
  let
    fixTreeMap : Tree a -> Tree b
    fixTreeMap tree =
      case tree of
        Leaf _ ->
          Leaf<b> ()

        Node node ->
          ??
  in
    fixTreeMap
