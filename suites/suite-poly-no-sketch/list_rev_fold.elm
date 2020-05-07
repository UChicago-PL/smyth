type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

fold : forall a . (List a -> a -> List a) -> List a -> List a -> List a
fold <a> f acc =
  let
    fixFold : forall a . List a -> List a
    fixFold <a> xs =
      case xs of
        Nil _ -> acc
        Cons p -> f (fixFold <a> (#2.2 p)) (#2.1 p)
  in
    fixFold <a>

snoc : List a -> a -> List a
snoc <a> xs n =
  case xs of
    Nil _ -> Cons (n, Nil ())
    Cons p -> Cons (#2.1 p, snoc <a> (#2.2 p) n)

listRevFold : forall a . List a -> List a
listRevFold <a> xs =
  ??
