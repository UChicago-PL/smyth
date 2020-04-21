specifyFunction treeCountLeaves
  [ (Leaf (), 1)
  , (Node (Leaf (), True, Leaf ()), 2)
  , (Node (Node (Leaf (), True, Leaf ()), True, Leaf ()), 3)
  , (Node (Leaf (), True, Node (Leaf (), True, Leaf ())), 3)
  , (Node (Node (Node (Leaf (), True, Leaf ()), True, Leaf ()), True, Leaf ()), 4)
  , (Node (Node (Leaf (), True, Leaf ()), True, Node (Leaf (), True, Leaf ())), 4)
  , (Node (Node (Leaf (), True, Leaf ()), True, Node (Node (Leaf (), True, Leaf ()), True, Node (Leaf (), True, Leaf ()))), 6)
  ]
