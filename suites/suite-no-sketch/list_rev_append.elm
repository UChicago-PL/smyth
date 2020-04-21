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
      Cons (get_2_1 p, append (get_2_2 p) l2)

listRevAppend : NatList -> NatList
listRevAppend xs =
  ??
