let read_all : in_channel -> string =
  fun channel ->
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

let read_file : string -> string =
  fun path ->
    let channel =
      open_in path
    in
    try
      read_all channel
    with e ->
      close_in_noerr channel;
      raise e

let visible_files : string -> string list =
  fun dir ->
    dir
      |> Sys.readdir
      |> Array.to_list
      |> List.filter
           ( fun file ->
               not (Sys.is_directory file)
                 && String.length file > 0
                 && String.get file 0 <> '.'
           )
      |> List.sort String.compare
