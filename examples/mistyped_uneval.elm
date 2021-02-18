type Nat
  = Z ()
  | S Nat

type NatList
  = Nil ()
  | Cons (Nat, NatList)

foo : (Nat -> NatList -> NatList) -> NatList
foo f = f 0 []

bar : NatList -> NatList
bar = ??

assert bar [] == []
