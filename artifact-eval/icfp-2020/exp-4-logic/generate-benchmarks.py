#!/usr/bin/python   # Python 2.7

import myth_benchmarks
  # TODO
  # make sure myth_benchmarks.py is in the same directory,
  # or is symlinked to experiments/myth_benchmarks.py
import re
from operator import itemgetter


def strJoin(sep, strings):
  return sep.join(strings)

def listConcat(xss):
  return [ x for xs in xss for x in xs ]

(FULL, FEWER) = ("1", "2a")
  # "FULL": Myth expert examples
  # "FEWER": Smyth expert examples


################################################################################

class Synquid:

  tool_name = "synquid"

  header = ""

  footer = ""

  Boolean = """
    data Boolean where
      T :: Boolean
      F :: Boolean
  """

  def makeBoolean(self, b):
    if b: return "T"
    else: return "F"

  Cmp = """
    data Cmp where
      LT :: Cmp
      EQ :: Cmp
      GT :: Cmp
  """

  Nat = """
    data Nat where
      Z :: Nat
      S :: Nat -> Nat

    termination measure dec :: Nat -> {Int | _v >= 0} where
      Z -> 0
      S m -> 1 + dec m
  """

  def makeNat(self, i):
    if i == 0:   return "Z"
    else:        return "(S " + self.makeNat(i-1) + ")"

  NatList = """
    data NatList where
      Nil :: NatList
      Cons :: Nat -> NatList -> NatList
    
    termination measure len :: NatList -> {Int | _v >= 0} where
      Nil -> 0
      Cons x xs -> 1 + len xs
  """

  def makeNatList(self, list):
    if len(list) == 0:
      return "Nil"
    else:
      return "(Cons " + self.makeNat(list[0]) + " " + self.makeNatList(list[1:]) + ")"

  NatListList = """
    data NatListList where
      LNil :: NatListList
      LCons :: NatList -> NatListList -> NatListList
    
    termination measure llen :: NatListList -> {Int | _v >= 0} where
      LNil -> 0
      LCons x xs -> 1 + llen xs
  """

  def makeNatListList(self, list):
    if len(list) == 0:
      return "LNil"
    else:
      return "(LCons " + self.makeNatList(list[0]) + " " + self.makeNatListList(list[1:]) + ")"

  BooleanList = """
    data BooleanList where
      Nil :: BooleanList
      Cons :: Boolean -> BooleanList -> BooleanList

    termination measure len :: BooleanList -> {Int | _v >= 0} where
      Nil -> 0
      Cons x xs -> 1 + len xs
  """

  def makeBooleanList(self, list):
    if len(list) == 0:
      return "Nil"
    else:
      return "(Cons " + self.makeBoolean(list[0]) + " " + self.makeBooleanList(list[1:]) + ")"

  NatOpt = """
    data NatOpt where
      None :: NatOpt
      Some :: Nat -> NatOpt
  """

  def makeNatOpt(self, no):
    if no: return "(Some " + self.makeNat(no) + ")"
    else:  return "None"

  NatTree = """
    data NatTree where
      Leaf :: NatTree
      Node :: NatTree -> Nat -> NatTree -> NatTree

    termination measure sizeTree :: NatTree -> {Int | _v >= 0} where
      Leaf -> 0
      Node left x right -> 1 + sizeTree left + sizeTree right
  """

  def makeNatTree(self, tree):
    if tree == ():
      return "Leaf"
    else:
      (left, n, right) = tree
      return "(Node " + self.makeNatTree(left) + " " + self.makeNat(n) + " " + self.makeNatTree(right) + ")"

  BooleanTree = """
    data BooleanTree where
      Leaf :: BooleanTree
      Node :: BooleanTree -> Boolean -> BooleanTree -> BooleanTree

    termination measure sizeTree :: BooleanTree -> {Int | _v >= 0} where
      Leaf -> 0
      Node left x right -> 1 + sizeTree left + sizeTree right
  """

  def makeBooleanTree(self, tree):
    if tree == ():
      return "Leaf"
    else:
      (left, n, right) = tree
      return "(Node " + self.makeBooleanTree(left) + " " + self.makeBoolean(n) + " " + self.makeBooleanTree(right) + ")"

  nat_add = """
    nat_add :: Nat -> Nat -> Nat
    nat_add = \\n1 . \\n2 .
      match n1 with
        Z   -> n2
        S m -> S (nat_add m n2)
  """

  nat_compare = """
    nat_compare :: Nat -> Nat -> Cmp
    nat_compare = \\n1 . \\n2 .
      match n1 with
        Z ->
          match n2 with
            Z   -> EQ
            S _ -> LT
        S m1 ->
          match n2 with
            Z    -> GT
            S m2 -> nat_compare m1 m2
  """

  list_append = """
    list_append :: NatList -> NatList -> NatList
    list_append = \\l1 . \\l2 .
      match l1 with
        Nil            -> l2
        Cons head tail -> Cons head (list_append tail l2)
  """

  list_snoc = """
    list_snoc :: NatList -> Nat -> NatList
    list_snoc = \\xs . \\n .
      match xs with
        Nil            -> Cons n Nil
        Cons head tail -> Cons head (list_snoc tail n)
  """

  list_map = """
    list_map :: NatList -> (Nat -> Nat) -> NatList
    list_map = \\xs . \\f .
      match xs with
        Nil            -> Nil
        Cons head tail -> Cons (f head) (list_map tail f)
  """

  list_fold = """
    list_fold :: (Nat -> Nat -> Nat) -> Nat -> NatList -> Nat
    list_fold = \\f . \\acc . \\xs .
      match xs with
        Nil            -> acc
        Cons head tail -> f (list_fold f acc tail) head
  """

  list_insert = """
    list_insert :: NatList -> Nat -> NatList
    list_insert = \\xs . \\n .
      match xs with
        Nil ->
          Cons n Nil
        Cons head tail ->
          match nat_compare n head with
            LT -> Cons n xs
            EQ -> xs
            GT -> Cons head (list_insert tail n)
  """

  boolean_list_append = \
    list_append.replace("NatList", "BooleanList")

  def makeMain(self, name, in_names_and_types, examples_with_types, which_examples):
    out_type = examples_with_types[0][2][1]
    args = \
      strJoin (" -> ",
        map (lambda (in_name, in_type): in_name + ":" + in_type, in_names_and_types)
      )
    examples = \
      strJoin (" &&\n",
        map (lambda (flag, inputs, (out_val, _)):
          ("   " if flag or which_examples == FULL else "-- ") +
          "(" +
            strJoin (" && ",
              map (lambda (in_val, (in_name, in_type)):
                # "(" + in_name + " == " + getattr(self, "make" + in_type)(in_val) + ")"
                in_name + " == " + getattr(self, "make" + in_type)(in_val)
              , inputs)
            ) +
            # " ==> (_v == " + getattr(self, "make" + out_type)(out_val) + ")" +
            " ==> _v == " + getattr(self, "make" + out_type)(out_val) + "" +
          ")"
        , examples_with_types)
      )
    s  = name + " :: " + args + " -> { " + out_type + " | \n\n"
    s += examples + " &&\n" + "   " + "True\n\n"
    s += "}\n"
    s += name + " = ??"
    return s

synquid = Synquid()


################################################################################

class Leon:

  tool_name = "leon"

  header = """
    import leon.lang._
    import leon.lang.synthesis._
    import leon.annotation._
    
    object Blah {
  """
  
  footer = """

    }"""
  
  Boolean = """
    sealed abstract class Boolean
    case object T extends Boolean
    case object F extends Boolean
  """

  def makeBoolean(self, b):
    if b: return "T"
    else: return "F"

  Cmp = """
    sealed abstract class Cmp
    case object LT extends Cmp
    case object EQ extends Cmp
    case object GT extends Cmp
  """

  Nat = """
    sealed abstract class Nat
    case class S(nat: Nat) extends Nat
    case object Z extends Nat
  """

  def makeNat(self, i):
    if i == 0:   return "Z"
    else:        return "S(" + self.makeNat(i-1) + ")"

  NatList = """
    sealed abstract class NatList
    case class Cons(head: Nat, tail: NatList) extends NatList
    case object Nil extends NatList
  """

  def makeNatList(self, list):
    if len(list) == 0:
      return "Nil"
    else:
      return "Cons(" + self.makeNat(list[0]) + ", " + self.makeNatList(list[1:]) + ")"

  NatListList = """
    sealed abstract class NatListList
    case class LCons(head: NatList, tail: NatListList) extends NatListList
    case object LNil extends NatListList
  """

  def makeNatListList(self, list):
    if len(list) == 0:
      return "LNil"
    else:
      return "LCons(" + self.makeNatList(list[0]) + ", " + self.makeNatListList(list[1:]) + ")"

  BooleanList = """
    sealed abstract class BooleanList
    case class Cons(head: Boolean, tail: BooleanList) extends BooleanList
    case object Nil extends BooleanList
  """

  def makeBooleanList(self, list):
    if len(list) == 0:
      return "Nil"
    else:
      return "Cons(" + self.makeBoolean(list[0]) + ", " + self.makeBooleanList(list[1:]) + ")"

  NatOpt = """
    sealed abstract class NatOpt
    case class Some(nat: Nat) extends NatOpt
    case object None extends NatOpt
  """

  def makeNatOpt(self, no):
    if no: return "Some(" + self.makeNat(no) + ")"
    else:  return "None"

  NatTree = """
    sealed abstract class NatTree
    case object Leaf extends NatTree
    case class Node(left: NatTree, n: Nat, right: NatTree) extends NatTree
  """

  def makeNatTree(self, tree):
    if tree == ():
      return "Leaf"
    else:
      (left, n, right) = tree
      return "Node(" + self.makeNatTree(left) + ", " + self.makeNat(n) + ", " + self.makeNatTree(right) + ")"

  BooleanTree = """
    sealed abstract class BooleanTree
    case object Leaf extends BooleanTree
    case class Node(left: BooleanTree, n: Boolean, right: BooleanTree) extends BooleanTree
  """

  def makeBooleanTree(self, tree):
    if tree == ():
      return "Leaf"
    else:
      (left, n, right) = tree
      return "Node(" + self.makeBooleanTree(left) + ", " + self.makeBoolean(n) + ", " + self.makeBooleanTree(right) + ")"

  nat_add = """
    def nat_add(n1: Nat, n2: Nat): Nat =
      n1 match {
        case Z    => n2
        case S(m) => S (nat_add(m, n2))
      }
  """

  nat_compare = """
    def nat_compare(n1: Nat, n2: Nat): Cmp =
      n1 match {
        case Z =>
          n2 match {
            case Z    => EQ
            case S(_) => LT
          }
        case S(m1) =>
          n2 match {
            case Z     => GT
            case S(m2) => nat_compare(m1, m2)
          }
      }
  """

  list_append = """
    def list_append(l1: NatList, l2: NatList): NatList =
      l1 match {
        case Nil              => l2
        case Cons(head, tail) => Cons (head, list_append(tail, l2))
      }
    """

  list_snoc = """
    def list_snoc(xs: NatList, n: Nat): NatList =
      xs match {
        case Nil             => Cons (n, Nil)
        case Cons(head,tail) => Cons (head, list_snoc(tail,n))
      }
  """

  list_map = """
    def list_map(xs: NatList, f: (Nat) => Nat): NatList =
      xs match {
        case Nil              => Nil
        case Cons(head, tail) => Cons (f(head), list_map(tail,f))
      }
  """

  list_fold = """
    def list_fold(f: (Nat,Nat) => Nat, acc: Nat, xs: NatList): Nat =
      xs match {
        case Nil              => acc
        case Cons(head, tail) => f (list_fold(f, acc, tail), head)
      }
  """

  list_insert = """
    def list_insert(xs: NatList, n: Nat): NatList =
      xs match {
        case Nil =>
          Cons (n, Nil)
        case Cons(head, tail) =>
          nat_compare(n, head) match {
            case LT => Cons (n, xs)
            case EQ => xs
            case GT => Cons (head, list_insert(tail, n))
          }
      }
  """

  boolean_list_append = \
    list_append.replace("NatList", "BooleanList")

  ## TODO a lot of copy-paste with Synquid.makeMain
  def makeMain(self, name, in_names_and_types, examples_with_types, which_examples):
    out_type = examples_with_types[0][2][1]
    num_args = len(in_names_and_types)
    args = \
      strJoin (", ",
        map (lambda (in_name, in_type): in_name + ": " + in_type, in_names_and_types)
      )
    examples = \
      strJoin (" &&\n",
        map (lambda (flag, inputs, (out_val, _)):
          ("   " if flag or which_examples == FULL else "// ") +
          "(" +
            ("(" if num_args > 1 else "") + # these extra parens are needed for Leon
            strJoin (" && ",
              map (lambda (in_val, (in_name, in_type)):
                "(" + in_name + " == " + getattr(self, "make" + in_type)(in_val) + ")"
              , inputs)
            ) +
            (")" if num_args > 1 else "") +
            " ==> (out == " + getattr(self, "make" + out_type)(out_val) + ")" +
          ")"
        , examples_with_types)
      )
    s  = "def " + name + "(" + args + "): " + out_type + " = { choose { (out:" + out_type + ") => \n\n"
    s += examples + " &&\n" + "   " + "true\n\n"
    s += "} }"
    return s

leon = Leon()


################################################################################

def write(tool_name, which_examples, name, string):
  subdir = "generated/" + ("1/" if which_examples == FULL else "2a/")
  filename = subdir + tool_name + "_" + name + ".txt"
  f = open(filename, "w")
  f.write(string)
  print "Wrote:", filename

def writeBenchmarkFile(tool, benchmark, which_examples):

  (name, context, in_names_and_types, out_type, examples) = benchmark

  ## These benchmarks:
  ##   (1) timeout in Experiment 1
  ##   (2) incorrect solution in Experiment 1
  ##   (3) expert examples in Experiment 2a same as in Experiment 1
  if which_examples == FEWER \
        and name in \
          [ "list_compress", "tree_binsert", "tree_nodes_at_level", "tree_postorder" # (1)
          , "list_even_parity"                                                       # (2)
          , "bool_neg", "bool_xor", "list_length", "nat_max"                         # (3)
          ]:
      ## ... so just generating "N/A" placeholders for Experiment 4-2a
      write(tool.tool_name, which_examples, name, "N/A\n")
      return

  examples_with_types = \
    map \
      ( lambda (flag, input_vals, out_val):
          (flag, zip(input_vals, in_names_and_types), (out_val, out_type))
      , examples
      )
  # print examples_with_types

  s = tool.header
  s += "".join(map(lambda context_def: getattr(tool, context_def), context)) + "\n"
  s += tool.makeMain(name, in_names_and_types, examples_with_types, which_examples)
  s += tool.footer
  s = re.sub(r'\n    ', "\n", s)
  # print s

  write(tool.tool_name, which_examples, name, s)


################################################################################

benchmarks = \
  listConcat (
    [ myth_benchmarks.bool_benchmarks
    , myth_benchmarks.list_benchmarks
    , myth_benchmarks.nat_benchmarks
    , myth_benchmarks.tree_benchmarks
    ]
  )

for benchmark in benchmarks:
  writeBenchmarkFile(leon, benchmark, FULL)
  writeBenchmarkFile(leon, benchmark, FEWER)
  writeBenchmarkFile(synquid, benchmark, FULL)
  writeBenchmarkFile(synquid, benchmark, FEWER)

print "#Benchmarks:", len(benchmarks)
