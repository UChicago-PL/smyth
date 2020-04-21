type Boolean
  = F ()
  | T ()

type BooleanTree
  = Leaf ()
  | Node (BooleanTree, Boolean, BooleanTree)

type BooleanList
  = Nil ()
  | Cons (Boolean, BooleanList)

append : BooleanList -> BooleanList -> BooleanList
append l1 l2 =
  case l1 of
    Nil _ ->
      l2
    Cons p ->
      Cons (get_2_1 p, append (get_2_2 p) l2)

treeCollectLeaves : BooleanTree -> BooleanList
treeCollectLeaves tree =
  case tree of
    Leaf _ ->
      Nil ()

    Node node ->
      ??
