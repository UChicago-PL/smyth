open Smyth
open Lang

type 'a t =
  ('a -> exp) * typ

let bool : bool t =
  ( begin fun b ->
      ECtor
        ( (if b then "T" else "F")
        , []
        , ETuple []
        )
    end
  , TData ("Boolean", [])
  )

let int : int t =
  ( Desugar.nat
  , TData ("Nat", [])
  )

let var : string t =
  ( begin fun x ->
      EVar x
    end
  , TData ("Polymorphic var unimplemented", [])
  )

let opt : 'a t -> 'a option t =
  fun (da, typ) ->
    ( begin fun x_opt ->
        match x_opt with
          | None ->
              ECtor ("None", [typ], ETuple [])

          | Some x ->
              ECtor ("Some", [typ], da x)
        end
    , TData ("Polymorphic opt unimplemented", [])
    )

let list : 'a t -> 'a list t =
  fun (da, typ) ->
    ( begin fun xs ->
        List.fold_right
          ( fun x acc ->
              ECtor ("Cons", [typ], ETuple [da x; acc])
          )
          xs
          (ECtor ("Nil", [typ], ETuple []))
      end
    , TData ("List", [typ])
    )

let nested_list : 'a t -> 'a list list t =
  fun d ->
    list (list d)

let tree : 'a t -> 'a Tree2.t t =
  fun (da, typ) ->
    ( let rec helper t =
        match t with
          | Tree2.Leaf ->
              ECtor ("Leaf", [typ], ETuple [])

          | Tree2.Node (left, x, right) ->
              ECtor
                ( "Node"
                , [typ]
                , ETuple
                    [ helper left
                    ; da x
                    ; helper right
                    ]
                )
      in
      helper
    , TData ("Tree", [typ])
    )

let args2 : 'a1 t -> 'a2 t -> ('a1 * 'a2) t =
  fun (da1, _) (da2, _) ->
    ( begin fun (x1, x2) ->
        ECtor ("args", [], ETuple [da1 x1; da2 x2])
      end
    , TData ("Polymorphic args2 unimplemented", [])
    )

let args3 : 'a1 t -> 'a2 t -> 'a3 t -> ('a1 * 'a2 * 'a3) t =
  fun (da1, _) (da2, _) (da3, _) ->
    ( begin fun (x1, x2, x3) ->
        ECtor ("args", [], ETuple [da1 x1; da2 x2; da3 x3])
      end
    , TData ("Polymorphic args3 unimplemented", [])
    )

let rec poly_to_mono : exp -> exp =
  function
    (* Main cases *)

    | EApp (_, e1, EAType _) ->
        poly_to_mono e1

    | ECtor (ctor_name, [TData ("List", _)], arg) ->
        ECtor ("L" ^ ctor_name, [], poly_to_mono arg)

    | ECtor (ctor_name, _, arg) ->
        ECtor (ctor_name, [], poly_to_mono arg)

    (* Other cases *)

    | EFix (f, x, body) ->
        EFix (f, x, poly_to_mono body)

    | EApp (special, e1, EAExp e2) ->
        EApp (special, poly_to_mono e1, EAExp (poly_to_mono e2))

    | EVar x ->
        EVar x

    | ETuple components ->
        ETuple (List.map poly_to_mono components)

    | EProj (n, i, arg) ->
        EProj (n, i, poly_to_mono arg)

    | ECase (scrutinee, branches) ->
        ECase
          ( poly_to_mono scrutinee
          , List.map (Pair2.map_snd (Pair2.map_snd poly_to_mono)) branches
          )

    | EHole hole_name ->
        EHole hole_name

    | EAssert (e1, e2) ->
        EAssert (poly_to_mono e1, poly_to_mono e2)

    | ETypeAnnotation (e, tau) ->
        ETypeAnnotation (poly_to_mono e, tau)

let poly : 'a t -> 'a -> exp =
  fun (da, _) x ->
    da x

let mono : 'a t -> 'a -> exp =
  fun d x ->
    poly_to_mono (poly d x)
