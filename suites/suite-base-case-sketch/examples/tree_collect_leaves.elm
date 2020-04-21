specifyFunction treeCollectLeaves
  [ -- (Leaf (), [])
  -- , (Node (Leaf (), True, Leaf ()), [True])
  -- , (Node (Leaf (), False, Leaf ()), [False])
  -- , (Node (Node (Leaf (), True, Leaf ()), False, Leaf ()), [True, False])
    (Node (Node (Leaf (), False, Leaf ()), True, Leaf ()), [False, True])
  , (Node (Leaf (), False, Node (Leaf (), True, Leaf ())), [False, True])
  ]
