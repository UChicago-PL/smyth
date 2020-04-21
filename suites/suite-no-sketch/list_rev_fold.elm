type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

fold : (NatList -> Nat -> NatList) -> NatList -> NatList -> NatList
fold f acc =
  let
    -- fixFold : NatList -> NatList
    fixFold xs =
      case xs of
        Nil _ -> acc
        Cons p -> f (fixFold (get_2_2 p)) (get_2_1 p)
  in
    fixFold

snoc : NatList -> Nat -> NatList
snoc xs n =
  case xs of
    Nil _ -> Cons (n, Nil ())
    Cons p -> Cons (get_2_1 p, snoc (get_2_2 p) n)

listRevFold : NatList -> NatList
listRevFold xs =
  ??
