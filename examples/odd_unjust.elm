type Nat
  = Z ()
  | S Nat

type Bool
  = False ()
  | True ()

type MaybeNat
  = Nothing ()
  | Just Nat

odd : Nat -> Bool
odd n =
  case n of
    Z _ ->
      False

    S n_ ->
      case n_ of
        Z _ ->
          True

        S n__ ->
          odd n__

unJust : MaybeNat -> Nat
unJust mx =
  case mx of
    Nothing _ ->
      0

    Just x ->
      x

assert odd (unJust ??) == True
