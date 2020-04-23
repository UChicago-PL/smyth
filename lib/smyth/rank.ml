open Lang

let rec size_rank : exp -> int =
  function
    | EFix (_, _, body) ->
        1 + size_rank body

    | EApp (_, e1, e2) ->
        1 + size_rank e1 + size_rank e2

    | EVar _ ->
        1

    | ETuple components ->
        1 + List2.sum (List.map size_rank components)

    | EProj (_, _, arg) ->
        (* "Focusing": projections don't add to the size rank *)
        size_rank arg

    | ECtor (_, arg) ->
        1 + size_rank arg

    | ECase (scrutinee, branches) ->
        1
          + size_rank scrutinee
          + List2.sum (List.map (fun (_, (_, e)) -> size_rank e) branches)

    | EHole _ ->
        1

    | EAssert (e1, e2) ->
        size_rank e1 + size_rank e2

    | ETypeAnnotation (e, _) ->
        (* Do not penalize for type annotations *)
        size_rank e

let rank =
  match Params.ranking_method with
    | Params.Size -> size_rank

let total_rank =
  List.map (fun (_, e) -> rank e) >> List2.sum

let sort :
 (hole_name * exp) list list -> (hole_name * exp) list list =
  List.sort
    ( fun hf1 hf2 ->
        Int.compare (total_rank hf1) (total_rank hf2)
    )

let first_recursive :
 (hole_name * exp) list list -> (hole_name * exp) list option =
  List.find_opt
    (List.map snd >> List.exists Exp.has_special_recursion)
