type Nat
  = Z ()
  | S Nat

plus : Nat -> Nat -> Nat
plus m n =
  case m of
    Z _ ->
      n

    S m_ ->
      S (plus m_ n)

mult : Nat -> Nat -> Nat
mult p q =
  case p of
    Z _ ->
      0

    S p_ ->
      plus ?? (mult ?? ??)

specifyFunction2 mult
  [ (2, 1, 2)
  , (3, 2, 6)
  ]
