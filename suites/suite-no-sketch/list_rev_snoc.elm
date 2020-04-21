type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

snoc : NatList -> Nat -> NatList
snoc xs n =
  case xs of
    Nil _ -> Cons (n, Nil ())
    Cons p -> Cons (get_2_1 p, snoc (get_2_2 p) n)

listRevSnoc : NatList -> NatList
listRevSnoc xs =
  ??
