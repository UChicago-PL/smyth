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

listMap : forall a . forall b . (a -> b) -> List a -> List b
listMap <a, b> f =
  let
    listMapFix : List a -> List b
    listMapFix xs =
      ??
  in
    listMapFix
