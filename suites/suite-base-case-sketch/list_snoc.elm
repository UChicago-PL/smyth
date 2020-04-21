type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listSnoc : NatList -> Nat -> NatList
listSnoc xs n =
  case xs of
    Nil _ ->
      Cons (n, Nil ())

    Cons p ->
      ??
