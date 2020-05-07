type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

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

listFilter : forall a . (a -> Boolean) -> List a -> List a
listFilter <a> predicate =
  let
    fixListFilter : List a -> List a
    fixListFilter xs =
      case xs of
        Nil _ ->
          Nil<a> ()

        Cons p ->
          ??
  in
    fixListFilter
