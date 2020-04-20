open Lang

let exp : exp -> exp =
  fun root ->
    Fresh.set_largest_hole (Exp.largest_hole root);
    let rec helper =
      function
        (* Main cases *)

          (* Handle constructor applications *)
        | EApp (special, e1, e2) ->
            let default () =
              EApp (special, helper e1, helper e2)
            in
            begin match e1 with
              | EVar name ->
                  if Char2.uppercase_char (String.get name 0) then
                    ECtor (name, helper e2)
                  else
                    default ()

              | _ ->
                  default ()
            end

          (* Handle syntactic sugar for unapplied constructors *)
        | EVar name ->
            if Char2.uppercase_char (String.get name 0) then
              ECtor (name, ETuple [])
            else
              EVar name

          (* Set proper hole names *)
        | EHole hole_name ->
            if Int.equal hole_name Fresh.unused then
              EHole (Fresh.gen_hole ())
            else
              EHole hole_name

        (* Other cases *)

        | EFix (f, x, body) ->
            EFix (f, x, helper body)

        | ETuple components ->
            ETuple (List.map helper components)

        | EProj (n, i, arg) ->
            EProj (n, i, helper arg)

        | ECtor (ctor_name, arg) ->
            ECtor (ctor_name, helper arg)

        | ECase (scrutinee, branches) ->
            ECase
              ( helper scrutinee
              , List.map (Pair2.map_snd (Pair2.map_snd helper)) branches
              )

        | EAssert (e1, e2) ->
            EAssert (helper e1, helper e2)

        | ETypeAnnotation (e, tau) ->
            ETypeAnnotation (helper e, tau)
    in
      helper root

