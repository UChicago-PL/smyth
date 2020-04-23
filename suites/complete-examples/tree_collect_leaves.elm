specifyFunction treeCollectLeaves
  [ (Leaf (), [])
  , (Node (Leaf (), T (), Leaf ()), [T ()])
  , (Node (Leaf (), F (), Leaf ()), [F ()])
  , (Node (Node (Leaf (), T (), Leaf ()), F (), Leaf ()), [T (), F ()])
  , (Node (Node (Leaf (), F (), Leaf ()), T (), Leaf ()), [F (), T ()])
  , (Node (Leaf (), F (), Node (Leaf (), T (), Leaf ())), [F (), T ()])
  ]
