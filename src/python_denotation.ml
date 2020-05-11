open Smyth
open Lang

let unsupported : string =
  "UNSUPPORTED"

let rec exp_collection : string -> string -> exp list -> string =
  fun left right es ->
    left ^ String.concat ", " (List.map exp es) ^ right

and exp : exp -> string =
  fun e ->
    match Sugar.nat e with
      | Some n ->
          string_of_int n

      | None ->
          begin match Sugar.listt e with
            | Some (exp_list, []) ->
                exp_collection "[" "]" exp_list

            | Some (_, _) ->
                unsupported

            | None ->
                begin match e with
                  | ECtor ("Leaf", [], ETuple [left; data; right]) ->
                      exp_collection "(" ")"
                        [left; data; right]

                  | ECtor ("Node", [], ETuple []) ->
                      "()"

                  | ECtor ("T", [], ETuple []) ->
                      "True"

                  | ECtor ("F", [], ETuple []) ->
                      "False"

                  | _ ->
                      unsupported
                end
          end
