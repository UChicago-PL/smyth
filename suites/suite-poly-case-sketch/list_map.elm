type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

zero : Nat -> Nat
zero n =
  Z ()

inc : Nat -> Nat
inc n =
  S n

listMap : (Nat -> Nat) -> NatList -> NatList
listMap f =
  let
    listMapFix : NatList -> NatList
    listMapFix xs =
      case xs of
        Nil _ ->
          Nil ()

        Cons p ->
          ??
  in
    listMapFix
