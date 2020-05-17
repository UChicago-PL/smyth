type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

append : NatList -> NatList -> NatList
append xs ys =
  case xs of
    Nil _ ->
      ys

    Cons p ->
      Cons (#2.1 p, append (#2.2 p) ys)

replicate : Nat -> Nat -> NatList
replicate n x =
  case n of
    Z _ ->
      ??

    S n_ ->
      ??

-- Arguments reversed for structural recursion checking
stutter_n : NatList -> Nat -> NatList
stutter_n xs n =
  case xs of
    Nil _ ->
      []

    Cons (u, us_) ->
      append (replicate n u) (stutter_n us_ n)

assert stutter_n [1, 0] 1 == [1, 0]
assert stutter_n [3]    2 == [3, 3]
