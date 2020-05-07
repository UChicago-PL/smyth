type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listTake : Nat -> NatList -> NatList
listTake n xs =
  case n of
    Z _ ->
      Nil ()

    S n_ ->
      ??
