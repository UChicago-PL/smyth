specifyFunction2 treeNodesAtLevel
  [ (Leaf (), 0, 0)
  , (Leaf (), 1, 0)
  , (Node (Leaf (), True, Leaf ()), 0, 1)
  , (Node (Leaf (), True, Leaf ()), 1, 0)
  , (Node (Node (Leaf (), True, Leaf ()), True, Leaf ()), 0, 1)
  , (Node (Node (Leaf (), True, Leaf ()), True, Leaf ()), 1, 1)
  , (Node (Node (Leaf (), True, Leaf ()), True, Node (Leaf (), True, Leaf ())), 0, 1)
  , (Node (Node (Leaf (), True, Leaf ()), True, Node (Leaf (), True, Leaf ())), 1, 2)
  , (Node (Node (Leaf (), True, Leaf ()), True, Node (Leaf (), True, Leaf ())), 2, 0)
  , (Node (Node (Node (Leaf (), True, Leaf ()), True, Node (Leaf (), True, Leaf ())), True, Leaf ()), 0, 1)
  , (Node (Node (Node (Leaf (), True, Leaf ()), True, Node (Leaf (), True, Leaf ())), True, Leaf ()), 1, 1)
  ]
