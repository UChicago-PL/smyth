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
  | ExpectingHole
  | ExpectingLambda
  | ExpectingSemicolon

  | ExpectingLet
  | ExpectingIn
  | ExpectingCase
  | ExpectingOf

  | ExpectingConstructorName
  | ExpectingVariableName

  | ExpectingTupleSize
  | ExpectingTupleIndex

type context =
  | CType
  | CTTuple
  | CTData
  | CTArr

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

type 'a parser =
  (context, problem, 'a) Bark.parser

val exp : exp parser

val typ : typ parser

type program =
  { datatypes : datatype_ctx
  ; bindings : string * (typ * exp) list
  ; assertions : exp * exp list
  ; main : exp option
  }

val program : program parser
