type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

fold : (NatList -> Nat -> NatList) -> NatList -> NatList -> NatList
fold f acc =
  let
    fixFold : NatList -> NatList
    fixFold xs =
      case xs of
        Nil _ -> acc
        Cons p -> f (fixFold (#2.2 p)) (#2.1 p)
  in
    fixFold

snoc : NatList -> Nat -> NatList
snoc xs n =
  case xs of
    Nil _ -> Cons (n, Nil ())
    Cons p -> Cons (#2.1 p, snoc (#2.2 p) n)

listRevFold : NatList -> NatList
listRevFold xs =
  ??
