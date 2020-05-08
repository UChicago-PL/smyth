specifyFunction2 (treeMap <Nat, Nat>)
  [ -- (div2, Leaf<Nat> (), Leaf<Nat> ())
  -- , (div2, Node<Nat> (Leaf<Nat> (), 0, Leaf<Nat> ()), Node<Nat> (Leaf<Nat> (), 0, Leaf<Nat> ()))
  -- , (div2, Node<Nat> (Leaf<Nat> (), 2, Leaf<Nat> ()), Node<Nat> (Leaf<Nat> (), 1, Leaf<Nat> ()))
    (div2, Node<Nat> (Node<Nat> (Leaf<Nat> (), 2, Leaf<Nat> ()), 2, Leaf<Nat> ()), Node<Nat> (Node<Nat> (Leaf<Nat> (), 1, Leaf<Nat> ()), 1, Leaf<Nat> ()))
  , (div2, Node<Nat> (Leaf<Nat> (), 1, Node<Nat> (Leaf<Nat> (), 2, Leaf<Nat> ())), Node<Nat> (Leaf<Nat> (), 0, Node<Nat> (Leaf<Nat> (), 1, Leaf<Nat> ())))
  -- , (inc, Leaf<Nat> (), Leaf<Nat> ())
  -- , (inc, Node<Nat> (Leaf<Nat> (), 0, Leaf<Nat> ()), Node<Nat> (Leaf<Nat> (), 1, Leaf<Nat> ()))
  ]
