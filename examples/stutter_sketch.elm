type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

stutter : NatList -> NatList
stutter xs =
  case xs of
    Nil _ ->
      []

    Cons (head, tail) ->
      ??

specifyFunction stutter
  [ -- ([], [])
    -- , ([0], [0, 0])
    ([1, 0], [1, 1, 0, 0])
  ]
