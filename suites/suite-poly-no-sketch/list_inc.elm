type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

map : forall a . List a -> (a -> a) -> List a
map <a> xs f =
  case xs of
    Nil _ -> Nil ()
    Cons p -> Cons (f (#2.1 p), map <a> (#2.2 p) f)

listInc : List Nat -> List Nat
listInc xs =
  ??
