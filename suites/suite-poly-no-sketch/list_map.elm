type Nat
  = Z ()
  | S Nat

type List a
  = Nil ()
  | Cons (a, List a)

zero : Nat -> Nat
zero n = Z ()

inc : Nat -> Nat
inc n = S n

listMap : forall a . (a -> a) -> List a -> List a
listMap <a> f =
  let
    listMapFix : forall a . List a -> List a
    listMapFix xs =
      ??
  in
    listMapFix
