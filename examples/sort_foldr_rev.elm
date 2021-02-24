type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

type Cmp
  = LT ()
  | EQ ()
  | GT ()

compare : Nat -> Nat -> Cmp
compare n1 n2 =
  case n1 of
    Z _ ->
      case n2 of
        Z _ -> EQ ()
        S _ -> LT ()
    S m1 ->
      case n2 of
        Z _  -> GT ()
        S m2 -> compare m1 m2

insert : Nat -> NatList -> NatList
insert n xs =
  case xs of
    Nil _ -> Cons (n, Nil ())
    Cons p ->
      case compare n (#2.1 p) of
        LT _ -> Cons (n, Cons p)
        EQ _ -> Cons (n, Cons p)
        GT _ -> Cons (#2.1 p, insert n (#2.2 p))

foldr : (Nat -> NatList -> NatList) -> NatList -> NatList -> NatList
foldr f acc xs =
  case xs of
    Nil _ ->
      acc

    Cons p ->
      f (#2.1 p) (foldr f acc (#2.2 p))

sort : NatList -> NatList
sort = ??

specifyFunction sort
  [ ([], [])
  , ([1], [1])
  , ([4], [4])
  , ([3,2], [2,3])
  , ([3,2,1], [1,2,3])
  ]
