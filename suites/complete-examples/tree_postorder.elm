specifyFunction treePostorder
  [ (Leaf (), [])
  , (Node (Leaf (), 1, Leaf ()), [1])
  , (Node (Leaf (), 2, Leaf ()), [2])
  , (Node (Node (Leaf (), 1, Leaf ()), 2, Leaf ()), [1, 2])
  , (Node (Leaf (), 1, Node (Leaf (), 2, Leaf ())), [2, 1])
  , (Node (Node (Leaf (), 1, Leaf ()), 0, Node (Leaf (), 2, Leaf ()) ), [1, 2, 0])
  , (Node (Node (Leaf (), 2, Leaf ()), 0, Node (Leaf (), 1, Leaf ()) ), [2, 1, 0])
  , (Node (Node (Node (Leaf (), 2, Leaf ()), 0, Node (Leaf (), 1, Leaf ()) ), 0, Leaf ()), [2, 1, 0, 0])
  , (Node (Leaf (), 2, Node (Node (Leaf (), 2, Leaf ()), 0, Node (Leaf (), 1, Leaf ()) )), [2, 1, 0, 2])
  ]
