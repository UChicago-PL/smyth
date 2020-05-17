open Smyth
open References

let experiment_proj :
 int -> (unit -> (Lang.exp * Lang.exp) list list list) reference_projection =
  fun n ->
    { proj =
        fun { function_name; k_max; d_in; d_out; input; base_case; func } ->
          fun () ->
            List.map
              ( fun k ->
                  List.map
                    ( List.map
                        ( fun (input_val, output_val) ->
                            let args =
                              match d_in input_val with
                                | Lang.ECtor ("args", [], Lang.ETuple args) ->
                                    args

                                | arg ->
                                    [arg]
                            in
                            ( Desugar.app
                                (Lang.EVar function_name)
                                (List.map (fun e -> Lang.EAExp e) args)
                            , d_out output_val
                            )
                        )
                    )
                    ( Sample2.io_trial ~n ~k func input base_case
                    )
              )
              ( List2.range ~low:0 ~high:k_max
              )
    }

let newline_regexp =
  Str.regexp " *\n+ *"

let left_paren_space_regexp =
  Str.regexp "( "

let space_right_paren_regexp =
  Str.regexp " )"

let space_comma_regexp =
  Str.regexp " ,"

let clean_string : string -> string =
  Str.global_replace newline_regexp " "
    >> Str.global_replace left_paren_space_regexp "("
    >> Str.global_replace space_right_paren_regexp ")"
    >> Str.global_replace space_comma_regexp ","

let specification_proj : string reference_projection =
  { proj =
      fun { function_name; k_max; d_in; d_out; input; base_case; func } ->
        match Sample2.io_trial ~n:1 ~k:k_max func input base_case with
          | [ios] ->
              let (arg_lens, inners) =
                ios
                  |> List.map
                       ( fun (input_val, output_val) ->
                           let args =
                             match d_in input_val with
                               | Lang.ECtor ("args", [], Lang.ETuple args) ->
                                   args

                               | arg ->
                                   [arg]
                           in
                           ( List.length args
                           , "(" ^
                              ( args @ [d_out output_val]
                                  |> List.map (Pretty.exp >> clean_string)
                                  |> String.concat ", "
                              ) ^
                              ")"
                           )
                       )
                  |> List.split
              in
              let arg_len =
                match List2.collapse_equal arg_lens with
                  | Some n ->
                      n

                  | None ->
                      failwith
                        "Unequal arg lengths in specification_proj"
              in
              let n_string =
                if Int.equal arg_len 1 then
                  ""
                else
                  string_of_int arg_len
              in
              "specifyFunction" ^ n_string ^ " " ^ function_name ^
              "\n  [ " ^ String.concat "\n  , " inners ^ "\n  ]"

          | _ ->
              failwith
                "Sample2.io_trial didn't return singleton in specification_proj"
  }
