type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

type Boolean
  = F ()
  | T ()

isEven : Nat -> Boolean
isEven n =
  case n of
    Z _  -> T ()
    S m1 ->
      case m1 of
        Z _  -> F ()
        S m2 -> isEven m2

isNonzero : Nat -> Boolean
isNonzero n =
  case n of
    Z _ -> F ()
    S _ -> T ()

listFilter : (Nat -> Boolean) -> NatList -> NatList
listFilter predicate =
  let
    fixListFilter : NatList -> NatList
    fixListFilter xs =
      case xs of
        Nil _ ->
          Nil ()

        Cons p ->
          ??
  in
    fixListFilter
