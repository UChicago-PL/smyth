type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

listLength : forall a . List a -> Nat
listLength <a> xs =
  ??
