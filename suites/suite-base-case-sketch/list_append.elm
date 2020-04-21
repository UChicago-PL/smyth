type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

append : NatList -> NatList -> NatList
append xs ys =
  case xs of
    Nil _ ->
      ys

    Cons p ->
      ??
