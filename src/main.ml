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

(* Commands *)

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
    String.concat " " (List.map (fun (name, _) -> "<" ^ name ^ ">") arguments) ^
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
            ~sketch:(Io.read_file Sys.argv.(2))
        with
          | Error e ->
              begin match e with
                | Endpoint.ParseError _ -> print_endline "Parse error."
                | Endpoint.TypeError _ -> print_endline "Type error."
                | Endpoint.EvalError _ -> print_endline "Eval error."
              end;
              exit 1

          | Ok hole_fillings ->
              hole_fillings
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
        let _ =
          Endpoint.test
            ~definitions:(Io.read_file Sys.argv.(2))
            ~complete_assertions:(Io.read_file Sys.argv.(3))
            ~partial_assertions:(Io.read_file Sys.argv.(4))
        in
        prerr_endline "Temporarily unsupported.";
  end;
  exit 0
