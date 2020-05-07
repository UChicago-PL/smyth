type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listNth : NatList -> Nat -> Nat
listNth xs n =
  ??
