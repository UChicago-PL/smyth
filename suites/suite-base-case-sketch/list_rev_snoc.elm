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
    Cons p -> Cons (#2.1 p, snoc (#2.2 p) n)

listRevSnoc : NatList -> NatList
listRevSnoc xs =
  case xs of
    Nil _ ->
      Nil ()

    Cons p ->
      ??
