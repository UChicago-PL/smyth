type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

snoc : forall a .  List a -> a -> List a
snoc <a> xs n =
  case xs of
    Nil _ -> Cons<a> (n, Nil<a> ())
    Cons p -> Cons<a> (#2.1 p, snoc <a> (#2.2 p) n)

listRevSnoc : forall a . List a -> List a
listRevSnoc <a> xs =
  case xs of
    Nil _ ->
      Nil<a> ()

    Cons p ->
      ??
