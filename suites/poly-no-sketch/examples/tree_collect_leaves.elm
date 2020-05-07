specifyFunction (treeCollectLeaves <Boolean>)
  [ (Leaf<Boolean> (), []<Boolean>)
  -- , (Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ()), [T ()]<Boolean>)
  -- , (Node<Boolean> (Leaf<Boolean> (), F (), Leaf<Boolean> ()), [F ()]<Boolean>)
  , (Node<Boolean> (Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ()), F (), Leaf<Boolean> ()), [T (), F ()]<Boolean>)
  -- , (Node<Boolean> (Node<Boolean> (Leaf<Boolean> (), F (), Leaf<Boolean> ()), T (), Leaf<Boolean> ()), [F (), T ()]<Boolean>)
  , (Node<Boolean> (Leaf<Boolean> (), F (), Node<Boolean> (Leaf<Boolean> (), T (), Leaf<Boolean> ())), [F (), T ()]<Boolean>)
  ]
