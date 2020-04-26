open Smyth
open Endpoint

let error : error -> string =
  function
    | ParseError _ ->
        "Parse error"

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

let test_result : test_result -> string =
  fun tr ->
    String.concat ","
      [ string_of_float tr.time_taken
      ; string_of_int tr.specification_assertion_count
      ; string_of_int tr.assertion_count
      ; string_of_bool tr.top_success
      ; string_of_bool tr.top_recursive_success
      ]
