type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

succ : Nat -> Nat
succ n =
  S n

foldr : (Nat -> Nat -> Nat) -> Nat -> NatList -> Nat
foldr f acc xs =
  case xs of
    Nil _ ->
      acc

    Cons p ->
      f (#2.1 p) (foldr f acc (#2.2 p))

length : NatList -> Nat
length xs =
  foldr (\x y -> ??) ?? ??

specifyFunction length
  [ ([0, 0], 2)
  ]
