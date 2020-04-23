open Smyth

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

(* Commands *)

type command =
  | Solve
  | Test
  | SuiteTest

let commands : command list =
  [ Solve; Test; SuiteTest ]

let command_name : command -> string =
  function
    | Solve -> "forge"
    | Test -> "test"
    | SuiteTest -> "suite-test"

let command_from_name : string -> command option =
  function
    | "forge" -> Some Solve
    | "test" -> Some Test
    | "suite-test" -> Some SuiteTest
    | _ -> None

let command_description : command -> string =
  function
    | Solve -> "Complete a program sketch"
    | Test -> "Test a solution against a specification"
    | SuiteTest -> "Test multiple solutions against specifications."

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
          , "The path to the sketch to be tested WITHOUT any assertions"
          )
        ; ( "assertions"
          , "The path to the assertions over " ^ arg_format "sketch"
          )
        ]

    | SuiteTest ->
        [ ( "specifications"
          , "The path to the directory of specifications"
          )
        ; ( "suite"
          , "The path to the suite to be tested"
          )
        ]

(* Help *)

let exec_name =
  Sys.argv.(0)

let usage_prefix =
  "Usage: " ^ exec_name

let command_help : command -> string =
  fun command ->
    let arguments =
      command_arguments command
    in
    usage_prefix ^ " " ^
    command_name command ^ " " ^
    String.concat " " (List.map (fun (name, _) -> arg_format name) arguments) ^
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
                 "  %-8s%s"
                 (command_name command)
                 (command_description command)
           )
      |> String.concat "\n"
  )

let help =
  title ^ "\n" ^
  name ^ " v" ^ Params.version ^ "\n" ^
  description ^ "\n\n" ^
  usage_prefix ^ " <command> <args>\n\n" ^
  available_commands ^
  "\n\nFor more specific information, run:\n\n  " ^
  exec_name ^ " <command> --help"

let command_not_found attempt =
  "Could not find command '" ^ attempt ^ "'.\n\n" ^
  available_commands

(* Main *)

let () =
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
            print_endline (command_not_found Sys.argv.(1));
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
  begin
    if argv_length - 2 <> List.length (command_arguments command) then
      begin
        print_endline (command_help command);
        exit 1
      end
    else
      ()
  end;
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
                |> List.map
                     ( fun hole_filling ->
                         hole_filling
                           |> List.map
                                ( fun (hole_name, exp) ->
                                    "??" ^ string_of_int hole_name ^ ": \n\n" ^
                                    Pretty.exp 0 exp
                                )
                           |> String.concat "\n\n"
                     )
                |> String.concat
                     "\n----------------------------------------\n\n"
                |> print_endline
        end

    | Test ->
        begin match
          Endpoint.test
            ~specification:(Io2.read_file Sys.argv.(2))
            ~sketch:(Io2.read_file Sys.argv.(3))
            ~assertions:(Io2.read_file Sys.argv.(4))
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
        let spec_path =
          Sys.argv.(2)
        in
        let suite_path =
          Sys.argv.(3)
        in
        let benchmark_names =
          Io2.visible_files suite_path
        in
        benchmark_names
          |> List.map
               ( fun name ->
                   begin match
                     Endpoint.test
                       ~specification:(Io2.read_path [spec_path; name])
                       ~sketch:(Io2.read_path [suite_path; name])
                       ~assertions:(Io2.read_path [suite_path; "examples"; name])
                   with
                     | Error e ->
                         "! error (" ^ name ^ "): " ^ Show.error e

                     | Ok test_result ->
                         name ^ "," ^ Show.test_result test_result
                   end
               )
          |> String.concat "\n"
          |> print_endline

  end;
  exit 0
