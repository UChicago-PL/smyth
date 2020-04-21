type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listHead : NatList -> Nat
listHead xs =
  ??
