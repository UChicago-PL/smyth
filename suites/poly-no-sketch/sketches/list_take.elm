type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

listTake : forall a . Nat -> List a -> List a
listTake <a> n xs =
  ??
