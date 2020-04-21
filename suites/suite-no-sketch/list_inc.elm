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
    Cons p -> Cons (f (get_2_1 p), map (get_2_2 p) f)

listInc : NatList -> NatList
listInc xs =
  ??
