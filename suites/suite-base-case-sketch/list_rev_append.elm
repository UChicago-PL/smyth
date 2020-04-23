type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

append : NatList -> NatList -> NatList
append l1 l2 =
  case l1 of
    Nil _ ->
      l2
    Cons p ->
      Cons (#2.1 p, append (#2.2 p) l2)

listRevAppend : NatList -> NatList
listRevAppend xs =
  case xs of
    Nil _ ->
      Nil ()

    Cons p ->
      ??
