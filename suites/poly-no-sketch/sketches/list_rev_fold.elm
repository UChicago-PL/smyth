type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

fold : forall a . forall b . (b -> a -> b) -> b -> List a -> b
fold <a, b> f acc =
  let
    fixFold : List a -> b
    fixFold xs =
      case xs of
        Nil _ -> acc
        Cons p -> f (fixFold (#2.2 p)) (#2.1 p)
  in
    fixFold

snoc : forall a . List a -> a -> List a
snoc <a> xs n =
  case xs of
    Nil _ -> Cons<a> (n, Nil<a> ())
    Cons p -> Cons<a> (#2.1 p, snoc <a> (#2.2 p) n)

listRevFold : forall a . List a -> List a
listRevFold <a> xs =
  ??
