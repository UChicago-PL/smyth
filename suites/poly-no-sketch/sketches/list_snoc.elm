type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

listSnoc : forall a . List a -> a -> List a
listSnoc <a> xs n =
  ??
