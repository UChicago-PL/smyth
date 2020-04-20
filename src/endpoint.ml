open Smyth

type error =
  | ParseError of (Parse.context, Parse.problem) Bark.dead_end list
  | TypeError of (Lang.exp * Type.error)
  | EvalError of string

type 'a response =
  ('a, error) result

let synthesis_pipeline delta sigma assertions =
  assertions
    |> Uneval.simplify_assertions delta sigma
    |> Solve.solve_any delta sigma

let solve ~sketch =
  begin match Bark.run Parse.program sketch with
    | Error e ->
        Error (ParseError e)

    | Ok program ->
        let (exp, sigma) =
          Desugar.program program
        in
        begin match Type.check sigma [] exp (Lang.TTuple []) with
          | Error e ->
              Error (TypeError e)

          | Ok delta ->
              begin match Eval.eval [] exp with
                | Error e ->
                    Error (EvalError e)

                | Ok (_, assertions) ->
                    let () =
                      Term_gen.clear_cache ()
                    in
										let clean_delta =
											List.map
												( Pair2.map_snd @@ fun (gamma, tau, dec, match_depth) ->
														( List.filter
																(fst >> Type.ignore_binding >> not)
																gamma
														, tau
														, dec
														, match_depth
														)
												)
												delta
										in
										let () =
											clean_delta
												|> List.map fst
												|> List2.maximum
												|> Option2.with_default 0
												|> Fresh.set_largest_hole
										in
										let () =
											Uneval.minimal_uneval := true
										in
                    let () =
                      Timer.Single.start Timer.Single.Total
                    in
										let minimal_synthesis_result =
											synthesis_pipeline clean_delta sigma assertions
										in
										let synthesis_result =
											if Nondet.is_empty minimal_synthesis_result then
												let () =
													Uneval.minimal_uneval := false
												in
                          synthesis_pipeline clean_delta sigma assertions
											else
												minimal_synthesis_result
										in
										Ok
                      ( synthesis_result
                          |> Nondet.map (fst >> Clean.clean clean_delta)
                          |> Nondet.collapse_option
                          |> Nondet.to_list
                      )
              end
        end
  end

let test ~definitions ~complete_assertions ~partial_assertions =
  let _ =
    (definitions, complete_assertions, partial_assertions)
  in
  raise Exit
