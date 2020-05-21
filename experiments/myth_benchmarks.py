
bool_benchmarks = \
  [
    ("bool_band", ["Boolean"], [("p", "Boolean"), ("q", "Boolean")], "Boolean",
      [ (True, [True, True], True)
      , (True, [True, False], False)
      , (True, [False, True], False)
      , (False, [False, False], False)
      ]
    )
  , ("bool_bor", ["Boolean"], [("p", "Boolean"), ("q", "Boolean")], "Boolean",
      [ (False, [True, True], True)
      , (True, [True, False], True)
      , (True, [False, True], True)
      , (True, [False, False], False)
      ]
    )
  , ("bool_impl", ["Boolean"], [("p", "Boolean"), ("q", "Boolean")], "Boolean",
      [ (True, [True, True], True)
      , (True, [True, False], False)
      , (False, [False, True], True)
      , (True, [False, False], True)
      ]
    )
  , ("bool_neg", ["Boolean"], [("p", "Boolean")], "Boolean",
      [ (True, [True], False)
      , (True, [False], True)
      ]
    )
  , ("bool_xor", ["Boolean"], [("p", "Boolean"), ("q", "Boolean")], "Boolean",
      [ (True, [True, True], False)
      , (True, [True, False], True)
      , (True, [False, True], True)
      , (True, [False, False], False)
      ]
    )
  ]

list_benchmarks = \
  [
    ("list_append", ["Nat", "NatList"], [("xs", "NatList"), ("ys", "NatList")], "NatList",
      [ (True, [[], []], [])
      , (False, [[], [0]], [0])
      , (False, [[0], []], [0])
      , (True, [[0], [0]], [0, 0])
      , (True, [[1, 0], []], [1, 0])
      , (True, [[1, 0], [0]], [1, 0, 0])
      ]
    )
  , ("list_compress", ["Nat", "NatList", "Cmp", "nat_compare"], [("xs", "NatList")], "NatList",
      [ (True, [[]], [])
      , (True, [[0]], [0])
      , (True, [[1]], [1])
      , (True, [[0, 0]], [0])
      , (True, [[1, 1]], [1])
      , (True, [[2, 0]], [2, 0])
      , (True, [[1, 0, 0]], [1, 0])
      , (True, [[0, 1, 1]], [0, 1])
      , (True, [[2, 1, 0, 0]], [2, 1, 0])
      , (True, [[2, 2, 1, 0, 0]], [2, 1, 0])
      , (True, [[2, 2, 0]], [2, 0])
      , (True, [[2, 2, 2, 0]], [2, 0])
      , (True, [[1, 2, 2, 2, 0]], [1, 2, 0])
      ]
    )
  , ("list_concat", ["Nat", "NatList", "NatListList", "list_append"], [("xss", "NatListList")], "NatList",
      [ (True, [[]], [])
      , (False, [[[]]], [])
      , (True, [[[0]]], [0])
      , (False, [[[0], [0]]], [0, 0])
      , (False, [[[1]]], [1])
      , (True, [[[1], [1]]], [1, 1])
      ]
    )
  , ("list_drop", ["Nat", "NatList"], [("xs", "NatList"), ("n", "Nat")], "NatList",
      [ (True, [[], 0], [])
      , (False, [[], 1], [])
      , (False, [[0], 0], [0])
      , (False, [[0], 1], [])
      , (True, [[1], 0], [1])
      , (True, [[1], 1], [])
      , (False, [[1, 0], 0], [1, 0])
      , (True, [[1, 0], 1], [0])
      , (False, [[0, 1], 0], [0, 1])
      , (False, [[0, 1], 1], [1])
      , (True, [[0, 1], 2], [])
      ]
    )
  , ("list_even_parity", ["Boolean", "BooleanList"], [("xs", "BooleanList")], "Boolean",
      [ (True, [[]], True)
      , (True, [[False]], True)
      , (True, [[True]], False)
      , (True, [[False, False]], True)
      , (True, [[False, True]], False)
      , (True, [[True, False]], False)
      , (True, [[True, True]], True)
      ]
    )
  , ("list_hd", ["Nat", "NatList"], [("xs", "NatList")], "Nat",
      [ (True, [[]], 0)
      , (False, [[0]], 0)
      , (True, [[1]], 1)
      ]
    )
  , ("list_inc", ["Nat", "NatList", "list_map"], [("xs", "NatList")], "NatList",
      [ (True, [[]], [])
      , (True, [[1, 2]], [2, 3])
      , (False, [[0, 0]], [1, 1])
      , (False, [[3, 4, 5]], [4, 5, 6])
      ]
    )
  , ("list_last", ["Nat", "NatList", "NatOpt"], [("xs", "NatList")], "NatOpt",
      [ (True, [[]], None)
      , (True, [[1]], 1)
      , (False, [[2]], 2)
      , (False, [[2, 1]], 1)
      , (True, [[1, 2]], 2)
      , (True, [[3, 2, 1]], 1)
      ]
    )
  , ("list_length", ["Nat", "NatList"], [("xs", "NatList")], "Nat",
      [ (True, [[]], 0)
      , (True, [[0]], 1)
      , (True, [[0, 0]], 2)
      ]
    )
  , ("list_nth", ["Nat", "NatList"], [("xs", "NatList"), ("n", "Nat")], "Nat",
      [ (False, [[], 0], 0)
      , (True, [[], 1], 0)
      , (False, [[2], 0], 2)
      , (True, [[2], 1], 0)
      , (True, [[1, 2], 0], 1)
      , (True, [[1, 2], 1], 2)
      , (False, [[1], 0], 1)
      , (False, [[1], 1], 0)
      , (True, [[2, 1], 0], 2)
      , (False, [[2, 1], 1], 1)
      , (False, [[3, 2, 1], 0], 3)
      , (False, [[3, 2, 1], 1], 2)
      , (False, [[3, 2, 1], 2], 1)
      ]
    )
  , ("list_pairwise_swap", ["Nat", "NatList"], [("xs", "NatList")], "NatList",
      [ (True, [[]], [])
      , (False, [[0]], [])
      , (True, [[1]], [])
      , (False, [[0, 1]], [1, 0])
      , (True, [[1, 0]], [0, 1])
      , (True, [[1, 0, 1]], [])
      , (True, [[0, 1, 0, 1]], [1, 0, 1, 0])
      ]
    )
  , ("list_rev_append", ["Nat", "NatList", "list_append"], [("l1", "NatList"), ("l2", "NatList")], "NatList",
      [ (True, [[]], [])
      , (True, [[0]], [0])
      , (False, [[1]], [1])
      , (False, [[0, 1]], [1, 0])
      , (True, [[0, 0, 1]], [1, 0, 0])
      ]
    )
  , ("list_rev_fold", ["Nat", "NatList", "list_fold", "list_snoc"], [("xs", "NatList")], "NatList",
      [ (True, [[]], [])
      , (False, [[0]], [0])
      , (False, [[1]], [1])
      , (True, [[0, 1]], [1, 0])
      , (False, [[0, 0, 1]], [1, 0, 0])
      ]
    )
  , ("list_rev_snoc", ["Nat", "NatList", "list_snoc"], [("xs", "NatList")], "NatList",
      [ (True, [[]], [])
      , (False, [[0]], [0])
      , (False, [[1]], [1])
      , (True, [[0, 1]], [1, 0])
      , (True, [[0, 0, 1]], [1, 0, 0])
      ]
    )
  , ("list_rev_tailcall", ["Nat", "NatList"], [("xs", "NatList"), ("acc", "NatList")], "NatList",
      [ (True, [[], []], [])
      , (False, [[], [0]], [0])
      , (False, [[], [1]], [1])
      , (False, [[], [1, 0]], [1, 0])
      , (True, [[0], []], [0])
      , (False, [[1], []], [1])
      , (False, [[1], [0]], [1, 0])
      , (True, [[0, 1], []], [1, 0])
      ]
    )
  , ("list_snoc", ["Nat", "NatList"], [("xs", "NatList"), ("n", "Nat")], "NatList",
      [ (True, [[], 0], [0])
      , (True, [[], 1], [1])
      , (False, [[0], 0], [0, 0])
      , (False, [[0], 1], [0, 1])
      , (False, [[1, 0], 0], [1, 0, 0])
      , (False, [[1, 0], 1], [1, 0, 1])
      , (False, [[2, 1, 0], 0], [2, 1, 0, 0])
      , (True, [[2, 1, 0], 1], [2, 1, 0, 1])
      ]
    )
  , ("list_sort_sorted_insert", ["Nat", "NatList", "Cmp", "nat_compare", "list_insert"], [("xs", "NatList")], "NatList",
      [ (True, [[]], [])
      , (False, [[0]], [0])
      , (False, [[1]], [1])
      , (False, [[0, 0]], [0])
      , (False, [[1, 0]], [0, 1])
      , (True, [[1, 1]], [1])
      , (True, [[0, 1, 1]], [0, 1])
      ]
    )
  , ("list_sorted_insert", ["Nat", "NatList", "Cmp", "nat_compare"], [("xs", "NatList"), ("n", "Nat")], "NatList",
      [ (True, [[], 0], [0])
      , (False, [[], 1], [1])
      , (False, [[], 2], [2])
      , (False, [[0], 0], [0])
      , (False, [[0], 1], [0, 1])
      , (False, [[1], 0], [0, 1])
      , (True, [[1], 1], [1])
      , (True, [[1], 2], [1, 2])
      , (True, [[2], 0], [0, 2])
      , (True, [[2], 1], [1, 2])
      , (True, [[0, 1], 0], [0, 1])
      , (True, [[0, 1], 2], [0, 1, 2])
      ]
    )
  , ("list_stutter", ["Nat", "NatList"], [("xs", "NatList")], "NatList",
      [ (True, [[]], [])
      , (False, [[0]], [0, 0])
      , (True, [[1, 0]], [1, 1, 0, 0])
      ]
    )
  , ("list_sum", ["Nat", "NatList", "list_fold", "nat_add"], [("xs", "NatList")], "Nat",
      [ (True, [[]], 0)
      , (False, [[1]], 1)
      , (True, [[2, 1]], 3)
      ]
    )
  , ("list_take", ["Nat", "NatList"], [("n", "Nat"), ("xs", "NatList")], "NatList",
      [ (True, [0, []], [])
      , (False, [0, [1]], [])
      , (True, [0, [0, 1]], [])
      , (False, [0, [1, 0, 1]], [])
      , (False, [1, []], [])
      , (True, [1, [1]], [1])
      , (True, [1, [0, 1]], [0])
      , (False, [1, [1, 0, 1]], [1])
      , (False, [2, []], [])
      , (False, [2, [1]], [1])
      , (False, [2, [0, 1]], [0, 1])
      , (True, [2, [1, 0, 1]], [1, 0])
      ]
    )
  , ("list_tl", ["Nat", "NatList"], [("xs", "NatList")], "NatList",
      [ (True, [[]], [])
      , (False, [[0]], [])
      , (True, [[0, 0]], [0])
      ]
    )
  ]

nat_benchmarks = \
  [
    ("nat_iseven", ["Nat", "Boolean"], [("n", "Nat")], "Boolean",
      [ (True, [0], True)
      , (False, [1], False)
      , (True, [2], True)
      , (True, [3], False)
      ]
    )
  , ("nat_max", ["Nat", "Boolean", "Cmp", "nat_compare"], [("n1", "Nat"), ("n2", "Nat")], "Nat",
      [ (True, [0, 0], 0)
      , (True, [0, 1], 1)
      , (True, [0, 2], 2)
      , (True, [1, 0], 1)
      , (True, [1, 1], 1)
      , (True, [1, 2], 2)
      , (True, [2, 0], 2)
      , (True, [2, 1], 2)
      , (True, [2, 2], 2)
      ]
    )
  , ("nat_pred", ["Nat"], [("n", "Nat")], "Nat",
      [ (True, [0], 0)
      , (False, [1], 0)
      , (True, [2], 1)
      ]
    )
  , ("nat_add", ["Nat"], [("in1", "Nat"), ("in2", "Nat")], "Nat",
      [ (True, [0, 0], 0)
      , (True, [0, 1], 1)
      , (False, [0, 2], 2)
      , (False, [1, 0], 1)
      , (False, [1, 1], 2)
      , (True, [1, 2], 3)
      , (True, [2, 0], 2)
      , (False, [2, 1], 3)
      , (False, [2, 2], 4)
      ]
    )
  ]

tree_benchmarks = \
  [
    ("tree_binsert", ["Nat", "NatTree", "Cmp", "nat_compare"], [("t", "NatTree"), ("n", "Nat")], "NatTree",
      [ (True, [(), 0], ((), 0, ()))
      , (True, [(), 1], ((), 1, ()))
      , (True, [(), 2], ((), 2, ()))
      , (True, [((), 1, ()), 0], (((), 0, ()), 1, ()))
      , (True, [((), 1, ()), 1], ((), 1, ()))
      , (True, [((), 1, ()), 2], ((), 1, ((), 2, ())))
      , (True, [((), 0, ()), 0], ((), 0, ()))
      , (True, [((), 0, ()), 1], ((), 0, ((), 1, ())))
      , (True, [((), 0, ()), 2], ((), 0, ((), 2, ())))
      , (True, [((), 2, ()), 0], (((), 0, ()), 2, ()))
      , (True, [((), 2, ()), 1], (((), 1, ()), 2, ()))
      , (True, [((), 2, ()), 2], ((), 2, ()))
      , (True, [(((), 0, ()), 1, ()), 0], (((), 0, ()), 1, ()))
      , (True, [(((), 0, ()), 1, ()), 1], (((), 0, ()), 1, ()))
      , (True, [(((), 0, ()), 1, ()), 2], (((), 0, ()), 1, ((), 2, ())))
      , (True, [((), 0, ((), 1, ())), 2], ((), 0, ((), 1, ((), 2, ()))))
      , (True, [(((), 1, ()), 2, ()), 0], ((((), 0, ()), 1, ()), 2, ()))
      , (True, [((), 1, ((), 2, ())), 0], (((), 0, ()), 1, ((), 2, ())))
      , (True, [((), 1, ((), 2, ())), 1], ((), 1, ((), 2, ())))
      , (True, [(((), 1, ()), 2, ()), 0], ((((), 0, ()), 1, ()), 2, ()))
      ]
    )
  , ("tree_collect_leaves", ["Boolean", "BooleanTree", "BooleanList", "boolean_list_append"], [("t", "BooleanTree")], "BooleanList",
      [ (True, [()], [])
      , (False, [((), True, ())], [True])
      , (False, [((), False, ())], [False])
      , (True, [(((), True, ()), False, ())], [True, False])
      , (False, [(((), False, ()), True, ())], [False, True])
      , (True, [((), False, ((), True, ()))], [False, True])
      ]
    )
  , ("tree_count_leaves", ["Nat", "Boolean", "BooleanTree", "nat_add"], [("t", "BooleanTree")], "Nat",
      [ (True, [()], 1)
      , (False, [((), True, ())], 2)
      , (True, [(((), True, ()), True, ())], 3)
      , (False, [((), True, ((), True, ()))], 3)
      , (False, [((((), True, ()), True, ()), True, ())], 4)
      , (True, [(((), True, ()), True, ((), True, ()))], 4)
      , (False, [(((), True, ()), True, (((), True, ()), True, ((), True, ())))], 6)
      ]
    )
  , ("tree_count_nodes", ["Nat", "NatTree", "nat_add"], [("t", "NatTree")], "Nat",
      [ (True, [()], 0)
      , (False, [((), 0, ())], 1)
      , (True, [(((), 0, ()), 0, ())], 2)
      , (False, [((), 0, ((), 0, ()))], 2)
      , (True, [(((), 0, ((), 0, ())), 0, ())], 3)
      , (False, [((), 0, ((), 0, ((), 0, ())))], 3)
      ]
    )
  , ("tree_inorder", ["Nat", "NatList", "NatTree", "list_append"], [("t", "NatTree")], "NatList",
      [ (True, [()], [])
      , (True, [((), 1, ())], [1])
      , (False, [((), 2, ())], [2])
      , (True, [(((), 1, ()), 2, ())], [1, 2])
      , (True, [((), 1, ((), 2, ()))], [1, 2])
      ]
    )
  , ("tree_nodes_at_level", ["Nat", "Boolean", "BooleanTree"], [("t", "BooleanTree"), ("n", "Nat")], "Nat",
      [ (True, [(), 0], 0)
      , (True, [(), 1], 0)
      , (True, [((), True, ()), 0], 1)
      , (True, [((), True, ()), 1], 0)
      , (True, [(((), True, ()), True, ()), 0], 1)
      , (True, [(((), True, ()), True, ()), 1], 1)
      , (True, [(((), True, ()), True, ((), True, ())), 0], 1)
      , (True, [(((), True, ()), True, ((), True, ())), 1], 2)
      , (True, [(((), True, ()), True, ((), True, ())), 2], 0)
      , (True, [((((), True, ()), True, ((), True, ())), True, ()), 0], 1)
      , (True, [((((), True, ()), True, ((), True, ())), True, ()), 1], 1)
      ]
    )
  , ("tree_postorder", ["Nat", "NatList", "NatTree", "list_append"], [("t", "NatTree")], "NatList",
      [ (True, [()], [])
      , (True, [((), 1, ())], [1])
      , (True, [((), 2, ())], [2])
      , (True, [(((), 1, ()), 2, ())], [1, 2])
      , (True, [((), 1, ((), 2, ()))], [2, 1])
      , (True, [(((), 1, ()), 0, ((), 2, ()))], [1, 2, 0])
      , (True, [(((), 2, ()), 0, ((), 1, ()))], [2, 1, 0])
      , (True, [((((), 2, ()), 0, ((), 1, ())), 0, ())], [2, 1, 0, 0])
      , (True, [((), 2, (((), 2, ()), 0, ((), 1, ())))], [2, 1, 0, 2])
      ]
    )
  , ("tree_preorder", ["Nat", "NatList", "NatTree", "list_append"], [("t", "NatTree")], "NatList",
      [ (True, [()], [])
      , (False, [((), 1, ())], [1])
      , (False, [((), 2, ())], [2])
      , (True, [(((), 1, ()), 2, ())], [2, 1])
      , (True, [((), 1, ((), 2, ()))], [1, 2])
      ]
    )
  ]
