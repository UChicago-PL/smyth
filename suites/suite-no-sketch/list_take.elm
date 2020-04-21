type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listTake : Nat -> NatList -> NatList
listTake n xs =
  ??
