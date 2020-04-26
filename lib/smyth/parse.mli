open Lang

type problem =
  | ExpectingLeftParen
  | ExpectingRightParen
  | ExpectingLeftBracket
  | ExpectingRightBracket
  | ExpectingComma
  | ExpectingRightArrow
  | ExpectingSpace
  | ExpectingPound
  | ExpectingDot
  | ExpectingEquals
  | ExpectingDoubleEquals
  | ExpectingHole
  | ExpectingLambda
  | ExpectingPipe
  | ExpectingColon
  | ExpectingFuncSpec

  | ExpectingWildcard
  | ExpectingLineComment
  | ExpectingMultiCommentStart
  | ExpectingMultiCommentEnd

  | ExpectingExactly of int * int

  | ExpectingMoreIndent

  | ExpectingLet
  | ExpectingIn
  | ExpectingCase
  | ExpectingOf
  | ExpectingType
  | ExpectingAssert

  | ExpectingNat

  | ExpectingConstructorName
  | ExpectingVariableName
  | ExpectingHoleName

  | ExpectingFunctionArity

  | ExpectingTupleSize
  | ExpectingTupleIndex

  | ExpectingName of string * string

  | NegativeArity of int
  | ZeroArity

  | ExpectingEnd
  [@@deriving yojson]

type context =
  | CType
  | CTTuple
  | CTData
  | CTArr

  | CPat
  | CPTuple
  | CPVar
  | CPWildcard

  | CExp
  | CELet
  | CEVar
  | CECtor
  | CETuple
  | CEProj
  | CEApp
  | CEHole
  | CELambda
  | CECase
  | CEList
  | CENat

  | CStatement
  | CSDatatype
  | CSDatatypeCtors
  | CSDefinition
  | CSAssertion
  | CSFuncSpec
  | CSFuncSpecInput
  | CSFuncSpecOutput

  | CProgram
  [@@deriving yojson]

type 'a parser =
  (context, problem, 'a) Bark.parser

val exp : exp parser

val typ : typ parser

val program : Desugar.program parser
