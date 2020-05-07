specifyFunction (treeCountLeaves <Boolean>)
  [ (Leaf<Boolean> (), 1)
  -- , (Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ()), 2)
  , (Node<Boolean> (Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ()), T (), Leaf<Boolean> ()), 3)
  -- , (Node<Boolean> (Leaf<Boolean> (), T (), Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ())), 3)
  -- , (Node<Boolean> (Node<Boolean> (Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ()), T (), Leaf<Boolean> ()), T (), Leaf<Boolean> ()), 4)
  , (Node<Boolean> (Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ()), T (), Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ())), 4)
  -- , (Node<Boolean> (Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ()), T (), Node<Boolean> (Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ()), T (), Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ()))), 6)
  ]
