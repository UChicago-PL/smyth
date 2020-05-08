specifyFunction (treeInOrder <Nat>)
  [ -- (Leaf<Nat> (), []<Nat>)
  -- , (Node<Nat> (Leaf<Nat> (), 1, Leaf<Nat> ()), [1]<Nat>)
  -- , (Node<Nat> (Leaf<Nat> (), 2, Leaf<Nat> ()), [2]<Nat>)
    (Node<Nat> (Node<Nat> (Leaf<Nat> (), 1, Leaf<Nat> ()), 2, Leaf<Nat> ()), [1, 2]<Nat>)
  , (Node<Nat> (Leaf<Nat> (), 1, Node<Nat> (Leaf<Nat> (), 2, Leaf<Nat> ())), [1, 2]<Nat>)
  ]
