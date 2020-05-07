type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

snoc : forall a . List a -> a -> List a
snoc <a> xs n =
  case xs of
    Nil _ -> Cons (n, Nil ())
    Cons p -> Cons (#2.1 p, snoc <a> (#2.2 p) n)

listRevSnoc : forall a . List a -> List a
listRevSnoc <a> xs =
  ??
