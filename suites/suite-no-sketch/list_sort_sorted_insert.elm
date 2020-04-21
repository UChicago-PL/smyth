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
      case compare n (get_2_1 p) of
        LT _ -> Cons (n, Cons (get_2_1 p, get_2_2 p))
        EQ _ -> xs
        GT _ -> Cons (get_2_1 p, insert (get_2_2 p) n)

listSortSortedInsert : NatList -> NatList
listSortSortedInsert xs =
  ??
