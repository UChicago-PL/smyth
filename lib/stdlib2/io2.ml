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
          close_in channel;
          !acc
      end
        |> List.rev
        |> String.concat "\n"

let read_file : string -> string =
  fun path ->
    read_all (open_in path)

let path : string list -> string =
  fun parts ->
    parts
      |> List2.concat_map (String.split_on_char '/')
      |> List.filter (fun s -> not (String.equal s ""))
      |> String.concat "/"

let read_path : string list -> string =
  fun parts ->
    parts
      |> path
      |> read_file

let visible_files : string -> string list =
  fun dir ->
    dir
      |> Sys.readdir
      |> Array.to_list
      |> List.filter
           ( fun file ->
               not (Sys.is_directory (path [dir; file]))
                 && String.length file > 0
                 && String.get file 0 <> '.'
           )
      |> List.sort String.compare
