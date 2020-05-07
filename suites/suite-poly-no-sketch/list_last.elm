type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

type Option a
  = None ()
  | Some a

listLast : forall a . List a -> Option a
listLast <a> xs =
  ??
