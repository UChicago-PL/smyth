type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listTail : NatList -> NatList
listTail xs =
  ??
