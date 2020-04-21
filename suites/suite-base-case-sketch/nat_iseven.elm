type Nat
  = Z ()
  | S Nat

type Boolean
  = F ()
  | T ()

isEven : Nat -> Boolean
isEven n =
  case n of
    Z _ ->
      T ()

    S n_ ->
      ??
