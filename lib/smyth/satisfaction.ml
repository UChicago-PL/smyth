open Lang

let rec res hf r ex =
  match (r, ex) with
    | (_, ExTop) ->
        true

    | (RTuple res_components, ExTuple ex_components) ->
        List.length res_components = List.length ex_components
          && List.for_all2 (res hf) res_components ex_components

    | (RCtor (r_name, r_arg), ExCtor (ex_name, ex_arg)) ->
        String.equal r_name ex_name
          && res hf r_arg ex_arg

    | (_, ExInputOutput (input, output)) ->
        begin match
          Eval.resume hf
            ( RApp
                ( r
                , RARes (Res.from_value input)
                )
            )
        with
          | Ok (r_out, []) ->
              res hf r_out output

          | _ ->
              false
        end

    | _ ->
        false

let exp hf e worlds =
  List.for_all
    ( fun (env, ex) ->
        match Eval.eval env e with
          | Ok (r, []) ->
              begin match Eval.resume hf r with
                | Ok (r', []) ->
                    res hf r' ex

                | _ ->
                    false
              end

          | _ ->
              false
    )
    worlds
