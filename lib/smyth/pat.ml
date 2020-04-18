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

let rec bind_res : pat -> res -> env option =
  fun p r ->
    match p with
      | PVar x ->
          Some [(x, r)]

      | PTuple ps ->
          begin match r with
            | RTuple rs ->
                if Int.equal (List.length ps) (List.length rs) then
                  List.map2 bind_res ps rs
                    |> Option2.sequence
                    |> Option2.map List.concat
                else
                  None

            | _ ->
                None
          end

      | PWildcard ->
          Some []

let bind_rec_name_res : string option -> res -> env =
  fun rec_name_opt r ->
    match rec_name_opt with
      | Some rec_name ->
          [(rec_name, r)]

      | None ->
          []

let rec bind_typ : bind_spec -> pat -> typ -> type_ctx option =
  fun bind_spec p tau ->
    match p with
      | PVar x ->
          Some [(x, (tau, bind_spec))]

      | PTuple ps ->
          begin match tau with
            | TTuple taus ->
                if Int.equal (List.length ps) (List.length taus) then
                  List.map2 (bind_typ bind_spec) ps taus
                    |> Option2.sequence
                    |> Option2.map List.concat
                else
                  None

            | _ ->
                None
          end

      | PWildcard ->
          Some []

let bind_rec_name_typ : string option -> typ -> type_ctx =
  fun rec_name_opt tau ->
    match rec_name_opt with
      | Some rec_name ->
          [(rec_name, (tau, Rec rec_name))]

      | None ->
          []
