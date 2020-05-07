specifyFunction2 treeNodesAtLevel
  [ (Leaf (), 0, 0)
  , (Leaf (), 1, 0)
  , (Node (Leaf (), T (), Leaf ()), 0, 1)
  , (Node (Leaf (), T (), Leaf ()), 1, 0)
  , (Node (Node (Leaf (), T (), Leaf ()), T (), Leaf ()), 0, 1)
  , (Node (Node (Leaf (), T (), Leaf ()), T (), Leaf ()), 1, 1)
  , (Node (Node (Leaf (), T (), Leaf ()), T (), Node (Leaf (), T (), Leaf ())), 0, 1)
  , (Node (Node (Leaf (), T (), Leaf ()), T (), Node (Leaf (), T (), Leaf ())), 1, 2)
  , (Node (Node (Leaf (), T (), Leaf ()), T (), Node (Leaf (), T (), Leaf ())), 2, 0)
  , (Node (Node (Node (Leaf (), T (), Leaf ()), T (), Node (Leaf (), T (), Leaf ())), T (), Leaf ()), 0, 1)
  , (Node (Node (Node (Leaf (), T (), Leaf ()), T (), Node (Leaf (), T (), Leaf ())), T (), Leaf ()), 1, 1)
  ]
