specifyFunction treeCountNodes
  [ (Leaf (), 0)
  -- , (Node (Leaf (), 0, Leaf ()), 1)
  , (Node (Node (Leaf (), 0, Leaf ()), 0, Leaf ()), 2)
  -- , (Node (Leaf (), 0, Node(Leaf (), 0, Leaf ())), 2)
  , (Node (Node (Leaf (), 0, Node (Leaf (), 0, Leaf ())), 0, Leaf ()), 3)
  -- , (Node (Leaf (), 0, Node (Leaf (), 0, Node (Leaf (), 0, Leaf ()))), 3)
  ]
