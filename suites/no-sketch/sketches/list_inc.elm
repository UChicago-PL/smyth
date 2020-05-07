type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

map : NatList -> (Nat -> Nat) -> NatList
map xs f =
  case xs of
    Nil _ -> Nil ()
    Cons p -> Cons (f (#2.1 p), map (#2.2 p) f)

listInc : NatList -> NatList
listInc xs =
  ??
