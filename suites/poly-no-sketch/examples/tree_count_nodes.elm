specifyFunction (treeCountNodes <Nat>)
  [ (Leaf<Nat> (), 0)
  -- , (Node<Nat> (Leaf<Nat> (), 0, Leaf<Nat> ()), 1)
  , (Node<Nat> (Node<Nat> (Leaf<Nat> (), 0, Leaf<Nat> ()), 0, Leaf<Nat> ()), 2)
  -- , (Node<Nat> (Leaf<Nat> (), 0, Node<Nat>(Leaf<Nat> (), 0, Leaf<Nat> ())), 2)
  , (Node<Nat> (Node<Nat> (Leaf<Nat> (), 0, Node<Nat> (Leaf<Nat> (), 0, Leaf<Nat> ())), 0, Leaf<Nat> ()), 3)
  -- , (Node<Nat> (Leaf<Nat> (), 0, Node<Nat> (Leaf<Nat> (), 0, Node<Nat> (Leaf<Nat> (), 0, Leaf<Nat> ()))), 3)
  ]
