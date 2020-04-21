type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listLength : NatList -> Nat
listLength xs =
  case xs of
    Nil _ ->
      Z ()

    Cons p ->
      ??
