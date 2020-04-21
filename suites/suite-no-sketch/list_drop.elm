type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listDrop : NatList -> Nat -> NatList
listDrop xs n =
  ??
