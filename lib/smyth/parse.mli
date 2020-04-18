open Lang

type problem =
  | ExpectingLeftParen
  | ExpectingRightParen
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

  | ExpectingWildcard

  | ExpectingMoreIndent

  | ExpectingLet
  | ExpectingIn
  | ExpectingCase
  | ExpectingOf
  | ExpectingType
  | ExpectingAssert

  | ExpectingConstructorName
  | ExpectingVariableName
  | ExpectingHoleName

  | ExpectingTupleSize
  | ExpectingTupleIndex

  | ExpectingName of string * string

  | ExpectingEnd

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

  | CStatement
  | CSDatatype
  | CSDatatypeCtors
  | CSDefinition
  | CSAssertion

  | CProgram

type 'a parser =
  (context, problem, 'a) Bark.parser

val exp : exp parser

val typ : typ parser

val program : Desugar.program parser
