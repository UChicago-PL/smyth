type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

listPairwiseSwap : forall a . List a -> List a
listPairwiseSwap <a> xs =
  ??
