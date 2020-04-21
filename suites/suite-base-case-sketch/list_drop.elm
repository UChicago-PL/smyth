type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listDrop : NatList -> Nat -> NatList
listDrop xs n =
  case n of
    Z _ ->
      xs

    S n_ ->
      ??
