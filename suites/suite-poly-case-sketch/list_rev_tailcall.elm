type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listRevTailcall : NatList -> NatList -> NatList
listRevTailcall xs acc =
  case xs of
    Nil _ ->
      acc

    Cons p ->
      ??
