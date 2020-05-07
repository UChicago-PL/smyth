type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

listTail : forall a . List a -> List a
listTail <a> xs =
  ??
