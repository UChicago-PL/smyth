open Smyth

(* Parameters *)

let forge_solution_count : int =
  3

let suite_test_n : int =
  5

(* Information *)

let title = "
  -_-/                    ,  ,,
 (_ /                    ||  ||
(_ --_  \\\\/\\\\/\\\\ '\\\\/\\\\ =||= ||/\\\\
  --_ ) || || ||  || ;'  ||  || ||
 _/  )) || || ||  ||/    ||  || ||
(_-_-   \\\\ \\\\ \\\\  |/     \\\\, \\\\ |/
                 (             _/
                  -_-
"

let name =
  "Smyth"

let description =
  "Programming-by-example in a typed functional language with sketches."

(* Helpers *)

let arg_format : string -> string =
  fun s ->
    "<" ^ s ^ ">"

let summarize : Endpoint.test_result list -> Endpoint.test_result option =
  fun test_results ->
    let open Option2.Syntax in
    let open Endpoint in
    let* head =
      List2.hd_opt test_results
    in
    let* _ =
      Option2.guard @@
        List.for_all
          ( fun (tr : test_result) ->
              { tr with time_taken = 0.0 } = { head with time_taken = 0.0 }
          )
          test_results
    in
    let+ average_time_taken =
      test_results
        |> List.map (fun (tr : test_result) -> tr.time_taken)
        |> List2.average
    in
    { head with
        time_taken = average_time_taken
    }

let ratio : int -> int -> float =
  fun x y ->
    (float_of_int x) /. (float_of_int y)

(* Commands *)

type command =
  | Solve
  | Test
  | SuiteTest
  | Fuzz
  | AssertionExport

let commands : command list =
  [ Solve; Test; SuiteTest; Fuzz; AssertionExport ]

let command_name : command -> string =
  function
    | Solve -> "forge"
    | Test -> "test"
    | SuiteTest -> "suite-test"
    | Fuzz -> "fuzz"
    | AssertionExport -> "assertion-export"

let command_from_name : string -> command option =
  fun name ->
    List.find_opt
      ( fun cmd ->
          String.equal (command_name cmd) name
      )
      commands

let command_description : command -> string =
  function
    | Solve ->
        "Complete a program sketch"

    | Test ->
        "Test a solution against a specification"

    | SuiteTest ->
        "Test multiple solutions against specifications"

    | Fuzz ->
        "Stress-test a program sketch with examples fuzzed from a built-in "
          ^ "function"

    | AssertionExport ->
        "Export a set of assertions to Python code"

let command_arguments : command -> (string * string) list =
  function
    | Solve ->
        [ ( "sketch"
          , "The path to the sketch to be completed"
          )
        ]

    | Test ->
        [ ( "specification"
          , "The path to the specification"
          )
        ; ( "sketch"
          , "The path to the sketch to be tested WITHOUT any examples"
          )
        ; ( "examples"
          , "The path to the examples for " ^ arg_format "sketch"
          )
        ]

    | SuiteTest ->
        [ ( "suite"
          , "The path to the suite to be tested"
          )
        ]

    | Fuzz ->
        [ ( "trial-count"
          , "The number of trials to run for each size of example set"
          )
        ; ( "built-in-func"
          , "The identifier of the built-in function to use as a reference"
          )
        ; ( "specification"
          , "The path to the specification"
          )
        ; ( "sketch"
          , "The path to the sketch to be fuzzed WITHOUT any examples"
          )
        ]

    | AssertionExport ->
        [ ( "specification"
          , "The path to the specification to be exported"
          )
        ; ( "examples"
          , "The path to the examples to be exported"
          )
        ]

(* Options *)

type prog_option =
  | Debug
  | MaxTotalTime

let prog_options : prog_option list =
  [ Debug; MaxTotalTime ]

let prog_option_name : prog_option -> string =
  function
    | Debug -> "debug"
    | MaxTotalTime -> "timeout"

let prog_option_from_name : string -> prog_option option =
  function
    | "debug" -> Some Debug
    | "timeout" -> Some MaxTotalTime
    | _ -> None

let prog_option_info : prog_option -> string * string * string list =
  function
    | Debug ->
        ( "Include debug logging"
        , "off"
        , ["off"; "on"]
        )

    | MaxTotalTime ->
        ( "Set maximum total time allowed per synthesis request"
        , Float2.to_string !Params.max_total_time
        , ["<positive-number>"]
        )

let prog_option_action : prog_option -> string -> bool =
  fun prog_option value ->
    match prog_option with
      | Debug ->
          begin match value with
            | "off" -> (Params.debug_mode := false; true)
            | "on" -> (Params.debug_mode := true; true)
            | _ -> false
          end

      | MaxTotalTime ->
          begin match float_of_string_opt value with
            | Some timeout -> (Params.max_total_time := timeout; true)
            | None -> false
          end

(* Help *)

let exec_name =
  Sys.argv.(0)

let usage_prefix =
  "Usage: " ^ exec_name

let option_schema =
  "[--option=value]*"

let command_help : command -> string =
  fun command ->
    let arguments =
      command_arguments command
    in
    usage_prefix ^ " " ^
    command_name command ^ " " ^
    String.concat " " (List.map (fun (name, _) -> arg_format name) arguments) ^
    " " ^ option_schema ^
    "\n\nArguments:\n" ^
    ( arguments
        |> List.map (fun (name, desc) -> Printf.sprintf "  %-22s%s" name desc)
        |> String.concat "\n"
    )


let available_commands =
  "Available commands:\n\n" ^
  ( commands
      |> List.map
           ( fun command ->
               Printf.sprintf
                 "  %-20s%s"
                 (command_name command)
                 (command_description command)
           )
      |> String.concat "\n"
  )

let available_options =
  "Available options:\n\n" ^
  ( prog_options
      |> List.map
           ( fun prog_option ->
               let name =
                 prog_option_name prog_option
               in
               let (description, default, possibles) =
                 prog_option_info prog_option
               in
               let possible_string =
                 String.concat "|" possibles
               in
               Printf.sprintf
                 "  %-12s(%s) %s. Default: %s"
                 name
                 possible_string
                 description
                 default
           )
      |> String.concat "\n"
  )

let help =
  title ^ "\n" ^
  name ^ " v" ^ Params.version ^ "\n" ^
  description ^ "\n\n" ^
  usage_prefix ^ " <command> <args> " ^ option_schema ^ "\n\n" ^
  available_commands ^
  "\n\n" ^
  available_options ^
  "\n\nFor more specific information, run:\n\n  " ^
  exec_name ^ " <command> --help"

let command_not_found attempt =
  "Could not find command '" ^ attempt ^ "'.\n\n" ^
  available_commands

(* Option handling *)

let handle_prog_option : string -> bool =
  fun arg ->
    let len =
      String.length arg
    in
    if len < 2 || arg.[0] <> '-' || arg.[1] <> '-' then
      false
    else
      match
        String.sub arg 2 (len - 2)
          |> String.split_on_char '='
      with
        | [name; value] ->
            begin match prog_option_from_name name with
              | Some prog_option ->
                  prog_option_action prog_option value

              | None ->
                  false
            end

        | _ ->
            false

let rec handle_prog_options : int -> string array -> unit =
  fun n prog_options ->
    if n >= Array.length prog_options then
      ()
    else
      begin
        if handle_prog_option prog_options.(n) then
          handle_prog_options (n + 1) prog_options
        else
          begin
            prerr_endline help;
            exit 1
          end
      end

(* Main *)

let () =
  Random.self_init ();
  let argv_length =
    Array.length Sys.argv
  in
  begin
    if argv_length < 2 then
      begin
        print_endline help;
        exit 0
      end
    else
      ()
  end;
  let command =
    match command_from_name Sys.argv.(1) with
      | Some cmd ->
          cmd

      | None ->
          begin
            prerr_endline (command_not_found Sys.argv.(1));
            exit 1
          end
  in
  begin
    if argv_length = 3 && Sys.argv.(2) = "--help" then
      begin
        print_endline (command_help command);
        exit 0
      end
    else
      ()
  end;
  let correct_arg_count =
    List.length (command_arguments command)
  in
  begin
    if argv_length - 2 < correct_arg_count then
      begin
        prerr_endline (command_help command);
        exit 1
      end
    else
      ()
  end;
  handle_prog_options (correct_arg_count + 2) Sys.argv;
  begin match command with
    | Solve ->
        begin match
          Endpoint.solve
            ~sketch:(Io2.read_file Sys.argv.(2))
        with
          | Error e ->
              prerr_endline (Show.error e);
              exit 1

          | Ok solve_result ->
              let hole_fillings =
                solve_result.Endpoint.hole_fillings
              in
              hole_fillings
                |> Rank.sort
                |> List2.take forge_solution_count
                |> List.mapi
                     ( fun i_ hole_filling ->
                         String.concat "\n\n"
                           [ "Solution #"
                               ^ (string_of_int (i_ + 1))
                               ^ " (rank: "
                               ^ string_of_int (Rank.rank hole_filling)
                               ^ ")"
                           ; hole_filling
                               |> List.map
                                    ( fun (hole_name, exp) ->
                                        "??"
                                          ^ string_of_int hole_name
                                          ^ ": \n\n"
                                          ^ Pretty.exp exp
                                    )
                               |> String.concat "\n\n"
                           ]
                     )
                |> String.concat
                     "\n--------------------------------------------------------------------------------\n"
                |> print_endline
        end

    | Test ->
        begin match
          Endpoint.test
            ~specification:(Io2.read_file Sys.argv.(2))
            ~sketch:(Io2.read_file Sys.argv.(3))
            ~examples:(Io2.read_file Sys.argv.(4))
        with
          | Error e ->
              prerr_endline (Show.error e);
              exit 1

          | Ok test_result ->
              test_result
                |> Show.test_result
                |> print_endline
        end

    | SuiteTest ->
        let suite_path =
          Sys.argv.(2)
        in
        let benchmark_names =
          Io2.visible_files (Io2.path [suite_path ; "sketches"])
        in
        print_endline ("% N = " ^ string_of_int suite_test_n);
        benchmark_names
          |> List.iter
               ( fun name ->
                   let output =
                     begin match
                       Result2.sequence @@
                         List.init suite_test_n
                           ( fun _ ->
                               Endpoint.test
                                 ~specification:
                                   ( Io2.read_path
                                       [suite_path; "specifications"; name]
                                   )
                                 ~sketch:
                                   ( Io2.read_path
                                       [suite_path; "sketches"; name]
                                   )
                                 ~examples:
                                   ( Io2.read_path
                                       [suite_path; "examples"; name]
                                   )
                           )
                     with
                       | Error e ->
                           "? error (" ^ name ^ "): " ^ Show.error e

                       | Ok test_results ->
                           match summarize test_results with
                             | Some test_result ->
                                 let prefix =
                                   let open Endpoint in
                                   if
                                     not test_result.top_success &&
                                     not test_result.top_recursive_success
                                   then
                                     "! failure: "
                                   else
                                     ""
                                 in
                                 prefix
                                  ^ name
                                  ^ ","
                                  ^ Show.test_result test_result

                             | None ->
                                 "? inconsistent test: " ^ name
                     end
                   in
                   print_endline output
               )

    | Fuzz ->
        let trial_count =
          match int_of_string_opt Sys.argv.(2) with
            | Some n when n > 0 ->
                n

            | _ ->
                prerr_endline "Trial count must be a positive integer.\n";
                prerr_endline (command_help command);
                exit 1
        in
        let builtin =
          Sys.argv.(3)
        in
        let spec_path =
          Sys.argv.(4)
        in
        let sketch_path =
          Sys.argv.(5)
        in
        let benchmark : (Lang.exp * Lang.exp) list list list =
          match
            List.assoc_opt
              builtin
              (Random_experiment.benchmarks trial_count)
          with
            | Some benchmark_thunk ->
                benchmark_thunk ()

            | None ->
                prerr_endline ("Unknown built-in function '" ^ builtin ^ "'.");
                exit 1
        in
        let results : (int * int) list =
          List.map
            ( fun trials ->
                let (top_successes, top_recursive_successes) =
                  trials
                    |> List.map
                         ( fun assertions ->
                             let open Endpoint in
                             match
                               Endpoint.test_assertions
                                 ~specification:(Io2.read_path [spec_path])
                                 ~sketch:(Io2.read_path [sketch_path])
                                 ~assertions:assertions
                             with
                               | Ok { top_success; top_recursive_success; _ } ->
                                   (top_success, top_recursive_success)

                               | Error Endpoint.TimedOut _
                               | Error Endpoint.NoSolutions ->
                                   (false, false)

                               | Error e ->
                                   prerr_endline
                                     ( "error for '"
                                         ^ sketch_path
                                         ^ "': "
                                         ^ Show.error e
                                     );
                                   exit 1
                         )
                    |> List.split
                in
                ( List2.count identity top_successes
                , List2.count identity top_recursive_successes
                )
            )
          benchmark
        in
        let result_string =
          builtin
            ^ "\ntimeout,"
            ^ Float2.to_string !Params.max_total_time
            ^ "\ntrial count,"
            ^ string_of_int trial_count
            ^ "\n"
            ^ "example count,top success percent,top recursive success percent"
            ^ "\n"
            ^ String.concat "\n"
                ( List.mapi
                    ( fun k (top_successes, top_recursive_successes) ->
                        ( Printf.sprintf "%d,%.4f,%.4f"
                            k
                            ( ratio
                                top_successes
                                trial_count
                            )
                            ( ratio
                                top_recursive_successes
                                trial_count
                            )
                        )
                    )
                    results
                )
        in
        print_endline result_string

    | AssertionExport ->
        begin match
          Endpoint.assertion_info
            ~specification:(Io2.read_file Sys.argv.(2))
            ~assertions:(Io2.read_file Sys.argv.(3))
        with
          | Error e ->
              print_endline
                ( "? error ("
                    ^ name
                    ^ "): "
                    ^ Show.error e
                )

          | Ok info ->
              let insides =
                info
                  |> List.map
                       ( fun (in_partial, inputs, output) ->
                           "("
                             ^ String.concat ", "
                                 [ if in_partial then
                                     "True"
                                   else
                                     "False"
                                 ; Python_denotation.exp_collection "[" "]"
                                     inputs
                                 ; Python_denotation.exp
                                     output
                                 ]
                             ^ ")"
                       )
              in
              print_endline
                ( "      [ "
                    ^ String.concat "\n      , " insides
                    ^ "\n      ]"
                )
        end
  end;
  exit 0
