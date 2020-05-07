type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (Nat, List a)

listStutter : forall a . List a -> List a
listStutter <a> xs =
  case xs of
    Nil _ ->
      Nil<a> ()

    Cons p ->
      ??
