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

