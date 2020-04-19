open Smyth

let exec_name =
  Sys.argv.(0)

let usage_prefix =
  "Usage: " ^ exec_name

type command =
  | Solve
  | Test

let commands : command list =
  [ Solve; Test ]

let command_name : command -> string =
  function
    | Solve -> "forge"
    | Test -> "test"

let command_from_name : string -> command option =
  function
    | "forge" -> Some Solve
    | "test" -> Some Test
    | _ -> None

let command_description : command -> string =
  function
    | Solve -> "Complete a program sketch"
    | Test -> "Compare solutions for different input-output examples"

let command_arguments : command -> (string * string) list =
  function
    | Solve ->
        [ ( "sketch"
          , "The path to the sketch to be completed"
          )
        ]

    | Test ->
        [ ( "definitions"
          , "The path to the sketch to be completed WITHOUT any assertions"
          )
        ; ( "complete_assertions"
          , "The path to the complete set of assertions"
          )
        ; ( "partial_assertions"
          , "The path to the partial set of assertions"
          )
        ]

let command_help : command -> string =
  fun command ->
    let arguments =
      command_arguments command
    in
    usage_prefix ^ " " ^
    command_name command ^ " " ^
    String.concat " " (List.map (fun (name, _) -> "<" ^ name ^ ">") arguments) ^
    "\n\nArguments:\n" ^
    ( arguments
        |> List.map (fun (name, desc) -> Printf.sprintf "  %-22s%s" name desc)
        |> String.concat "\n"
    )

let synthesis_pipeline delta sigma assertions =
  assertions
    |> Uneval.simplify_assertions delta sigma
    |> Solve.solve_any delta sigma

let version_string =
  "0.1.0"

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


let available_commands =
  "Available commands:\n\n" ^
  ( commands
      |> List.map (fun c -> Printf.sprintf "  %-8s%s" (command_name c) (command_description c))
      |> String.concat "\n"
  )

let help =
  title ^ "\n" ^
  name ^ " v" ^ version_string ^ "\n" ^
  description ^ "\n\n" ^
  usage_prefix ^ " <command> <args>\n\n" ^
  available_commands ^
  "\n\nFor more specific information, run:\n\n  " ^
  exec_name ^ " <command> --help"

let command_not_found attempt =
  "Could not find command '" ^ attempt ^ "'.\n\n" ^
  available_commands

let read_all channel =
  let acc =
    ref []
  in
    begin try
      while true do
        acc := input_line channel :: !acc
      done;
      !acc
    with
      End_of_file ->
        !acc
    end
      |> List.rev
      |> String.concat "\n"

let read_file path =
  let channel =
    open_in path
  in
  try
    read_all channel
  with e ->
    close_in_noerr channel;
    raise e

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
        let sketch_path =
          Sys.argv.(2)
        in
        let sketch_string =
          read_file sketch_path
        in
        begin match Bark.run Parse.program sketch_string with
          | Error _ ->
              print_endline "Parse error.";
              exit 1

          | Ok program ->
              let (exp, _sigma) =
                Desugar.program program
              in
              print_endline (Pretty.exp 0 exp)
        end

    | Test ->
        let _sketch_path =
          Sys.argv.(2)
        in
        let _complete_assertions_path =
          Sys.argv.(3)
        in
        let _partial_assertions_path =
          Sys.argv.(4)
        in
        prerr_endline "Temporarily unsupported."
  end;
  exit 0
