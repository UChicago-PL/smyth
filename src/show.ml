open Smyth
open Endpoint

let parse_problem : Parse.problem -> string =
  fun p ->
    let expecting s =
      "Expecting " ^ s
    in
    let expecting_symbol s =
      expecting @@ "symbol '" ^ s ^ "'"
    in
    let expecting_keyword s =
      expecting @@ "keyword '" ^ s ^ "'"
    in
    let open Parse in
    match p with
      | ExpectingLeftParen -> expecting_symbol "("
      | ExpectingRightParen -> expecting_symbol ")"
      | ExpectingLeftBracket -> expecting_symbol "["
      | ExpectingRightBracket -> expecting_symbol "]"
      | ExpectingComma -> expecting_symbol ","
      | ExpectingRightArrow -> expecting_symbol "->"
      | ExpectingLAngle -> expecting_symbol "<"
      | ExpectingRAngle -> expecting_symbol ">"
      | ExpectingSpace -> expecting "spaces"
      | ExpectingPound -> expecting_symbol "#"
      | ExpectingDot -> expecting_symbol "."
      | ExpectingEquals -> expecting_symbol "="
      | ExpectingDoubleEquals -> expecting_symbol "=="
      | ExpectingHole -> expecting_symbol "??"
      | ExpectingLambda -> expecting_symbol "\\"
      | ExpectingPipe -> expecting_symbol "|"
      | ExpectingColon -> expecting_symbol ":"
      | ExpectingFuncSpec -> expecting "function specification"

      | ExpectingWildcard -> expecting "wildcard pattern"
      | ExpectingLineComment -> expecting "line comment"
      | ExpectingMultiCommentStart -> expecting "multi-line comment start"
      | ExpectingMultiCommentEnd -> expecting "multi-line comment end"

      | ExpectingExactly (n, got) ->
          expecting @@
            "exactly " ^ string_of_int n ^ ", got " ^ string_of_int got

      | ExpectingMoreIndent -> expecting "more indentation"

      | ExpectingLet -> expecting_keyword "let"
      | ExpectingIn -> expecting_keyword "in"
      | ExpectingCase -> expecting_keyword "case"
      | ExpectingOf -> expecting_keyword "of"
      | ExpectingType -> expecting_keyword "type"
      | ExpectingAssert -> expecting_keyword "assert"

      | ExpectingNat -> expecting "natural number"

      | ExpectingConstructorName -> expecting "constructor name"
      | ExpectingVariableName -> expecting "variable name"
      | ExpectingHoleName -> expecting "hole name"

      | ExpectingFunctionArity -> expecting "function arity"

      | ExpectingTupleSize -> expecting "tuple size"
      | ExpectingTupleIndex -> expecting "tuple index"

      | ExpectingName (name, got) ->
          expecting "name '" ^ name ^ "', got '" ^ got ^ "'"

      | NegativeArity arity ->
          "Negative function arity: " ^ string_of_int arity

      | ZeroArity ->
          "Zero function arity"

      | ExpectingEnd ->
          expecting "EOF"

let parse_dead_end : (Parse.context, Parse.problem) Bark.dead_end -> string =
  fun dead_end ->
    let open Bark in
    "[row="
      ^ string_of_int dead_end.row
      ^ ", col="
      ^ string_of_int dead_end.col
      ^ "] "
      ^ parse_problem dead_end.problem


let error : error -> string =
  function
    | ParseError dead_ends ->
        "Parse error:\n"
          ^ String.concat "\n" (List.map parse_dead_end dead_ends)

    | TypeError (exp, te) ->
        "Type error: "
          ^ (Yojson.Safe.to_string @@ Type.error_to_yojson te)
          ^ " in "
          ^ Pretty.exp exp

    | EvalError e ->
        "Eval error: " ^ e

    | TimedOut _ ->
        "Timed out"

    | NoSolutions ->
        "No solutions"

    | PartialNotSubsetFull ->
        "Error: examples are not a subset of the specification"

let test_result : test_result -> string =
  fun tr ->
    String.concat ","
      [ Float2.to_string tr.time_taken
      ; string_of_int tr.specification_assertion_count
      ; string_of_int tr.assertion_count
      ; string_of_bool tr.top_success
      ; string_of_bool tr.top_recursive_success
      ]
