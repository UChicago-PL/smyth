open Lang

let rec from_value v =
  match v with
    | VTuple comps ->
        ExTuple (List.map from_value comps)

    | VCtor (name, v_arg) ->
        ExCtor (name, from_value v_arg)

let rec to_value ex =
  match ex with
    | ExTuple exs ->
        exs
          |> List.map to_value
          |> Option2.sequence
          |> Option.map (fun vs -> VTuple vs)

    | ExCtor (name, arg) ->
        Option.map
          (fun v_arg -> VCtor (name, v_arg))
          (to_value arg)

    | ExInputOutput (_, _) ->
        None

    | ExTop ->
        None
