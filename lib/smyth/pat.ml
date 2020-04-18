open Lang

let rec syntactically_equal : pat -> pat -> bool =
  fun p1 p2 ->
    match (p1, p2) with
      | (PVar x1, PVar x2) ->
          String.equal x1 x2

      | (PTuple ps1, PTuple ps2) ->
          Int.equal (List.length ps1) (List.length ps2)
            && List.for_all2 syntactically_equal ps1 ps2

      | (PWildcard, PWildcard) ->
          true

      | _ ->
          false

let rec bind : pat -> res -> env option =
  fun p r ->
    match p with
      | PVar x ->
          Some [(x, r)]

      | PTuple ps ->
          begin match r with
            | RTuple rs ->
                if Int.equal (List.length ps) (List.length rs) then
                  List.map2 bind ps rs
                    |> Option2.sequence
                    |> Option2.map List.concat
                else
                  None

            | _ ->
                None
          end

      | PWildcard ->
          Some []

let bind_var_opt : string option -> res -> env =
  fun var_opt r ->
    match var_opt with
      | Some var ->
          [(var, r)]

      | None ->
          []
