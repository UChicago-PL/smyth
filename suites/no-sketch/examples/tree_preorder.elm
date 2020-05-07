specifyFunction treePreorder
  [ (Leaf (), [])
  -- , (Node (Leaf (), 1, Leaf ()), [1])
  -- , (Node (Leaf (), 2, Leaf ()), [2])
  , (Node (Node (Leaf (), 1, Leaf ()), 2, Leaf ()), [2, 1])
  , (Node (Leaf (), 1, Node (Leaf (), 2, Leaf ())), [1, 2])
  ]
