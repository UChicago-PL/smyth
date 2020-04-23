type error =
  | ParseError of (Parse.context, Parse.problem) Bark.dead_end list
  | TypeError of (Lang.exp * Type.error)
  | EvalError of string
  | TimedOut of float
  | NoSolutions

type 'a response =
  ('a, error) result

(* Program Helpers *)

let parse_program : string -> Desugar.program response =
  Bark.run Parse.program
    >> Result.map_error (fun e -> ParseError e)

(* Solve *)

type solve_result =
  { hole_fillings : (Lang.hole_name * Lang.exp) list list
  ; time_taken : float
  }

let synthesis_pipeline delta sigma assertions =
  assertions
    |> Uneval.simplify_assertions delta sigma
    |> Solve.solve_any delta sigma

let solve_program : Desugar.program -> solve_result response =
  fun program ->
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
                let time_taken =
                  Timer.Single.elapsed Timer.Single.Total;
                in
                let timed_out =
                  time_taken > Params.max_total_time
                in
                if timed_out then
                  Error (TimedOut time_taken)
                else
                  Ok
                    { hole_fillings =
                        synthesis_result
                          |> Nondet.map (fst >> Clean.clean clean_delta)
                          |> Nondet.collapse_option
                          |> Nondet.to_list
                    ; time_taken
                    }
          end
    end


let solve ~sketch =
  sketch
    |> parse_program
    |> Result2.and_then solve_program

(* Test *)

type test_result =
  { time_taken : float
  ; specification_assertion_count : int
  ; assertion_count : int
  ; top_success : bool
  ; top_recursive_success : bool
  }

let check :
 Desugar.program ->
 (Lang.hole_name * Lang.exp) list
 -> bool response =
  fun program hole_filling ->
    let (exp_with_holes, sigma) =
      Desugar.program program
    in
    let exp =
      List.fold_left
        ( fun acc binding ->
            Exp.fill_hole binding acc
        )
        exp_with_holes
        hole_filling
    in
    match Type.check sigma [] exp (Lang.TTuple []) with
      | Error e ->
          Error (TypeError e)

      | Ok _ ->
          begin match Eval.eval [] exp with
            | Error e ->
                Error (EvalError e)

            | Ok (_, assertions) ->
                Ok (List2.is_empty assertions)
          end

let test ~specification ~sketch ~assertions =
  let open Desugar in
  let open Result2.Syntax in
  let* full_assertions =
    specification
      |> parse_program
      |> Result.map (fun prog -> prog.assertions)
  in
  let* partial_assertions =
    assertions
      |> parse_program
      |> Result.map (fun prog -> prog.assertions)
  in
  let* sketch_program =
    parse_program sketch
  in
  let* { hole_fillings; time_taken } =
    solve_program
      { sketch_program with assertions = partial_assertions }
  in
  let ranked_hole_fillings =
    Rank.sort hole_fillings
  in
  let* top_success =
    ranked_hole_fillings
      |> List2.hd_opt
      |> Option.to_result ~none:NoSolutions
      |> Result2.and_then
           (check { sketch_program with assertions = full_assertions })
  in
  let+ top_recursive_success =
    ranked_hole_fillings
      |> Rank.first_recursive
      |> Option.map
           (check { sketch_program with assertions = full_assertions })
      |> Option2.with_default (Ok false)
  in
  { time_taken
  ; specification_assertion_count =
      List.length full_assertions
  ; assertion_count =
      List.length partial_assertions
  ; top_success
  ; top_recursive_success
  }

