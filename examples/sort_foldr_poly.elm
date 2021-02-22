type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

type Cmp
  = LT ()
  | EQ ()
  | GT ()

foldr : forall a . (a -> List a -> List a) -> List a -> List a -> List a
foldr <a> f acc xs =
  case xs of
    Nil _ ->
      acc

    Cons p ->
      f (#2.1 p) (foldr <a> f acc (#2.2 p))

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

insert : Nat -> List Nat -> List Nat
insert n xs =
  case xs of
    Nil _ -> [n]<Nat> 
    Cons p ->
      case compare n (#2.1 p) of
        LT _ -> Cons<Nat> (n, Cons<Nat> (#2.1 p, #2.2 p))
        EQ _ -> xs
        GT _ -> Cons<Nat> (#2.1 p, insert n (#2.2 p))

sort : List Nat -> List Nat
sort = ??

specifyFunction sort
  [ ([]<Nat>, []<Nat>)
  , ([1]<Nat>, [1]<Nat>)
  , ([4]<Nat>, [4]<Nat>)
  , ([3,2]<Nat>, [2,3]<Nat>)
  , ([3,2,1]<Nat>, [1,2,3]<Nat>)
  ]
