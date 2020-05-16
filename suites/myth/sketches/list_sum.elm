type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

fold : (Nat -> Nat -> Nat) -> Nat -> NatList -> Nat
fold f acc =
  let
    fixFold : NatList -> Nat
    fixFold xs =
      case xs of
        Nil _ -> acc
        Cons p -> f (fixFold (#2.2 p)) (#2.1 p)
  in
    fixFold

add : Nat -> Nat -> Nat
add n1 n2 =
  case n1 of
    Z _ -> n2
    S m -> S (add m n2)

listSum : NatList -> Nat
listSum xs =
  ??
