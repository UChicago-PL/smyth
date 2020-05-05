type Nat
  = Z ()
  | S Nat

type Boolean
  = F ()
  | T ()

id : forall a . a -> a
id <a> x =
  x

const : forall a . forall b . a -> b -> a
const <a, b> x y =
  x

specifyFunction2 (const <Nat, Boolean>)
  [ (2, F (), 2)
  ]
