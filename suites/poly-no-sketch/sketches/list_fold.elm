type Nat
  = Z ()
  | S Nat

type Boolean
  = F ()
  | T ()

type List a
  = Nil ()
  | Cons (a, List a)

sum : Nat -> Nat -> Nat
sum n1 n2 =
  case n1 of
    Z _ -> n2
    S m -> S (sum m n2)

isOdd : Nat -> Boolean
isOdd n =
  case n of
    Z _  -> F ()
    S m1 ->
      case m1 of
        Z _  -> T ()
        S m2 -> isOdd m2

countOdd : Nat -> Nat -> Nat
countOdd n1 n2 =
  case isOdd n2 of
    T _ -> S n1
    F _ -> n1

listFold : forall a . forall b . (b -> a -> b) -> b -> List a -> b
listFold <a, b> f acc =
  let
    fixListFold : List a -> b
    fixListFold xs =
      ??
  in
    fixListFold
