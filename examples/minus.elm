type Nat
  = Z ()
  | S Nat

minus : Nat -> Nat -> Nat
minus a b =
  let
    hole : Nat
    hole =
      ??
  in
  case a of
    Z _ ->
      hole

    S a_ ->
      case b of
        Z _ ->
          hole

        S b_ ->
          minus ?? ??

specifyFunction2 minus
  [ (2, 0, 2)
  , (3, 2, 1)
  , (3, 1, 2)
  ]
