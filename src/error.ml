open Smyth

let show : Endpoint.error -> string =
  function
    | Endpoint.ParseError _ ->
        "Parse error"

    | Endpoint.TypeError _ ->
        "Type error"

    | Endpoint.EvalError _ ->
        "Eval error"

    | Endpoint.TimedOut _ ->
        "Timed out"

    | Endpoint.NoSolutions ->
        "No solutions"
