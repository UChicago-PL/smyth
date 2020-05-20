open Smyth
open Lang

let unsupported : string =
  "UNSUPPORTED"

let rec listt : exp -> exp list option =
  function
    | ECtor ("Cons" , [], ETuple [head; tail])
    | ECtor ("LCons", [], ETuple [head; tail]) ->
        Option.map
          (fun es -> head :: es)
          (listt tail)

    | ECtor ("Nil" , [], ETuple [])
    | ECtor ("LNil", [], ETuple []) ->
        Some []

    | _ ->
        None

let rec exp_collection : string -> string -> exp list -> string =
  fun left right es ->
    left ^ String.concat ", " (List.map exp es) ^ right

and exp : exp -> string =
  fun e ->
    match Sugar.nat e with
      | Some n ->
          string_of_int n

      | None ->
          begin match listt e with
            | Some exp_list ->
                exp_collection "[" "]" exp_list

            | None ->
                begin match e with
                  | ECtor ("Node", [], ETuple [left; data; right]) ->
                      exp_collection "(" ")"
                        [left; data; right]

                  | ECtor ("Leaf", [], ETuple []) ->
                      "()"

                  | ECtor ("T", [], ETuple []) ->
                      "True"

                  | ECtor ("F", [], ETuple []) ->
                      "False"

                  | ECtor ("Some", [], arg) ->
                      exp arg

                  | ECtor ("None", [], ETuple []) ->
                      "None"

                  | EVar name ->
                      "'" ^ name ^ "'"

                  | _ ->
                      unsupported
                end
          end
