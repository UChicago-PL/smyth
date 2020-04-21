type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listLength : NatList -> Nat
listLength xs =
  ??
