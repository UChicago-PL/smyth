type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

listRevTailcall : forall a . List a -> List a -> List a
listRevTailcall <a> xs acc =
  case xs of
    Nil _ ->
      acc

    Cons p ->
      ??
