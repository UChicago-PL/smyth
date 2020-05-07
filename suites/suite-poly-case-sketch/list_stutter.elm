type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listStutter : NatList -> NatList
listStutter xs =
  case xs of
    Nil _ ->
      Nil ()

    Cons p ->
      ??
