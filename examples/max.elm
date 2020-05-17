type Nat
  = Z ()
  | S Nat

max : Nat -> Nat -> Nat
max m n =
  case m of
    Z _ ->
      n

    S m_ ->
      case n of
        Z _ ->
          m

        S n_ ->
          ??

specifyFunction2 max
  [ (1, 1, 1)
  , (1, 2, 2)
  , (3, 1, 3)
  ]
