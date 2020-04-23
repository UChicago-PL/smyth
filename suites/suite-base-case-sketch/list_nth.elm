type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listNth : NatList -> Nat -> Nat
listNth xs n =
  case n of
    Z _ ->
      case xs of
        Nil _ ->
          Z ()

        Cons p ->
          #2.1 p

    S n_ ->
      ??
