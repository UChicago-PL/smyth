type Nat
  = Z ()
  | S Nat

type Boolean
  = F ()
  | T ()

id : forall a . a -> a
id <a> x =
  x

const : forall b . b -> (forall a . a -> a) -> b
const <b> x f =
  f <b> x

specifyFunction3 const
  [ (<Nat>, 2, id, 2)
  , (<Boolean>, T (), id, T ())
  ]
