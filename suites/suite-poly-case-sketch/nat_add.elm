type Nat
  = Z ()
  | S Nat

natAdd : Nat -> Nat -> Nat
natAdd m n =
  case m of
    Z _ ->
      n

    S m_ ->
      ??
