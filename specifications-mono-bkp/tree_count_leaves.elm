specifyFunction treeCountLeaves
  [ (Leaf (), 1)
  , (Node (Leaf (), T (), Leaf ()), 2)
  , (Node (Node (Leaf (), T (), Leaf ()), T (), Leaf ()), 3)
  , (Node (Leaf (), T (), Node (Leaf (), T (), Leaf ())), 3)
  , (Node (Node (Node (Leaf (), T (), Leaf ()), T (), Leaf ()), T (), Leaf ()), 4)
  , (Node (Node (Leaf (), T (), Leaf ()), T (), Node (Leaf (), T (), Leaf ())), 4)
  , (Node (Node (Leaf (), T (), Leaf ()), T (), Node (Node (Leaf (), T (), Leaf ()), T (), Node (Leaf (), T (), Leaf ()))), 6)
  ]
