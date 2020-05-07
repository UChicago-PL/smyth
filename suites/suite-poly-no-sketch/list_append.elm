type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

append : forall a . List a -> List a -> List a
append <a> xs ys =
  ??
