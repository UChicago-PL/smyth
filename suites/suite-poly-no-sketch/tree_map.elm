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

treeMap : forall a . (a -> a) -> Tree a -> Tree a
treeMap <a> f =
  let
    fixTreeMap : forall a . Tree a -> Tree a
    fixTreeMap <a> tree =
      ??
  in
    fixTreeMap <a>
