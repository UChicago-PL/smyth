type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listSnoc : NatList -> Nat -> NatList
listSnoc xs n =
  ??
