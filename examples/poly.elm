type Nat
  = Z ()
  | S Nat

type Boolean
  = F ()
  | T ()

choose : forall a . a -> a -> a
choose <a> x y =
  ??

specifyFunction3 choose
  [ (<Nat>, 1, 0, 1)
  -- Won't work if added:
  -- , (<Nat>, 0, 1, 1)
  ]
