open Lang

let lett : string -> exp -> exp -> exp =
  fun name binding body ->
    EApp (false, EFix (Some name, name, body), binding)

let rec replace_var : (string -> exp) -> exp -> exp =
  fun replacer exp ->
    let recur =
      replace_var replacer
    in
    match exp with
      (* Main case *)

      | EVar name ->
          replacer name

      (* Other cases *)

      | EFix (f, x, body) ->
          EFix (f, x, recur body)

      | EApp (special, e1, e2) ->
          EApp (special, recur e1, recur e2)

      | ETuple components ->
          ETuple (List.map recur components)

      | EProj (n, i, arg) ->
          EProj (n, i, recur arg)

      | ECtor (ctor_name, arg) ->
          ECtor (ctor_name, recur arg)

      | ECase (scrutinee, branches) ->
          ECase
            ( recur scrutinee
            , List.map (Pair2.map_snd (Pair2.map_snd recur)) branches
            )

      | EHole hole_name ->
          EHole hole_name

      | EAssert (e1, e2) ->
          EAssert (recur e1, recur e2)

      | ETypeAnnotation (e, tau) ->
          ETypeAnnotation (recur e, tau)

let tuple_counter =
  ref 0

let fresh_tuple_name : unit -> string =
  fun () ->
    let name =
      "$tuple_" ^ string_of_int !tuple_counter
    in
    tuple_counter := !tuple_counter + 1;
    name

let tuple_pattern : string list * exp -> string * exp =
  fun (xs, body) ->
    let tuple_name =
      fresh_tuple_name ()
    in
    let tuple_var =
      EVar tuple_name
    in
    let tuple_length =
      List.length xs
    in
    let indexes =
      List2.index_right xs
    in
    ( tuple_name
    , replace_var
        ( fun name ->
            match List.assoc_opt name indexes with
              | Some index ->
                  EProj (tuple_length, index, tuple_var)

              | None ->
                  EVar name
        )
        body
    )

let case : exp -> (string * (string list * exp)) list -> exp =
  fun scrutinee branches ->
    ECase (scrutinee, List.map (Pair2.map_snd tuple_pattern) branches)

type program =
  { datatypes : datatype_ctx
  ; definitions : (string * typ * exp) list
  ; assertions : (exp * exp) list
  ; main_opt : exp option
  }

let program : program -> exp * datatype_ctx =
  fun { datatypes; definitions; assertions; main_opt } ->
    ( List.fold_right
        ( fun (name, the_typ, the_exp) ->
            lett name (ETypeAnnotation (the_exp, the_typ))
        )
        definitions
        ( List.fold_right
            ( fun (e1, e2) ->
                lett "_" (EAssert (e1, e2))
            )
            assertions
            ( Option2.with_default (ETuple [])
                main_opt
            )
        )
    , datatypes
    )
