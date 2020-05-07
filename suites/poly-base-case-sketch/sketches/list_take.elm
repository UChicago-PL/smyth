type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (Nat, List a)

listTake : forall a . Nat -> List a -> List a
listTake <a> n xs =
  case n of
    Z _ ->
      Nil<a> ()

    S n_ ->
      ??
