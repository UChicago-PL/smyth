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

insert : NatList -> Nat -> NatList
insert xs n =
  case xs of
    Nil _ -> Cons (n, Nil ())
    Cons p ->
      case compare n (#2.1 p) of
        LT _ -> Cons (n, Cons (#2.1 p, #2.2 p))
        EQ _ -> xs
        GT _ -> Cons (#2.1 p, insert (#2.2 p) n)

listSortSortedInsert : NatList -> NatList
listSortSortedInsert xs =
  case xs of
    Nil _ ->
      Nil ()

    Cons p ->
      ??
