type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

listHead : forall a . List a -> a
listHead <a> xs =
  ??
