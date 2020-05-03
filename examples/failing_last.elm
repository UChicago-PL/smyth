type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

type NatOpt
  = None ()
  | Some Nat

listLast : NatList -> NatOpt
listLast xs =
  ??

specifyFunction listLast
  [ ([], None ())
  , ([2, 3], Some 3)
  , ([1, 1, 2, 0], Some 0)
  , ([3, 0, 0, 3], Some 3)
  , ([2, 0, 0, 0], Some 0)
  ]
