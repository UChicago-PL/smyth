type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

revConcat : NatList -> NatList -> NatList
revConcat xs ys =
  case xs of
    Nil _ ->
      ??

    Cons (head, tail) ->
      ??

assert revConcat [] [1] == [1]
assert revConcat [0, 1] [2, 3] == [1, 0, 2, 3]
assert revConcat [4] [5] == [4, 5]
