type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

listStutter : NatList -> NatList
listStutter xs = ??

specifyFunction listStutter
  [ ([], [])
  , ([1, 0], [1, 1, 0, 0])
  ]
