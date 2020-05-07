type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listPairwiseSwap : NatList -> NatList
listPairwiseSwap xs =
  case xs of
    Nil _ ->
      Nil ()

    Cons p ->
      ??
