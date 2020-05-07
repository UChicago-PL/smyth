type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

listRevTailcall : List a -> List a -> List a
listRevTailcall <a> xs acc =
  ??
