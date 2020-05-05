open Lang

let rec nat : exp -> int option =
  function
    | ECtor ("S", [], arg) ->
        Option.map ((+) 1) (nat arg)

    | ECtor ("Z", [], ETuple []) ->
        Some 0

    | _ ->
        None

let rec listt : exp -> exp list option =
  function
    | ECtor ("Cons", [], ETuple [head; tail]) ->
        Option.map (List.cons head) (listt tail)

    | ECtor ("Nil", [], ETuple []) ->
        Some []

    | _ ->
        None
