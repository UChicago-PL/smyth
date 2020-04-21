type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

type NatOpt
  = None ()
  | Some Nat

listLast : NatList -> NatOpt
listLast xs =
  case xs of
    Nil _ ->
      None ()

    Cons p ->
      ??
