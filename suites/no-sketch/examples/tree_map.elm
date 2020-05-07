specifyFunction2 treeMap
  [ (div2, Leaf (), Leaf ())
  -- , (div2, Node (Leaf (), 0, Leaf ()), Node (Leaf (), 0, Leaf ()))
  -- , (div2, Node (Leaf (), 2, Leaf ()), Node (Leaf (), 1, Leaf ()))
  , (div2, Node (Node (Leaf (), 2, Leaf ()), 2, Leaf ()), Node (Node (Leaf (), 1, Leaf ()), 1, Leaf ()))
  , (div2, Node (Leaf (), 1, Node (Leaf (), 2, Leaf ())), Node (Leaf (), 0, Node (Leaf (), 1, Leaf ())))
  -- , (inc, Leaf (), Leaf ())
  , (inc, Node (Leaf (), 0, Leaf ()), Node (Leaf (), 1, Leaf ()))
  ]
