open Lang

(* Types *)

let rec equal tau1 tau2 =
  match (tau1, tau2) with
    | (TArr (tau11, tau12), TArr (tau21, tau22)) ->
        equal tau11 tau21 && equal tau12 tau22

    | (TTuple taus1, TTuple taus2) ->
        List.length taus1 = List.length taus2
          && List.for_all2 equal taus1 taus2

    | (TData d1, TData d2) ->
        String.equal d1 d2

    | _ ->
        false

let is_base tau =
  match tau with
    | TArr _ ->
        false

    | TTuple _ ->
        false

    | TData _ ->
        true

    | TForall (_, _) ->
        false

    | TVar _ ->
        true

let rec domain_of_codomain ~codomain tau =
  match tau with
    | TArr (tau1, tau2) ->
        if equal codomain tau2 then
          Some tau1
        else
          domain_of_codomain ~codomain tau2

    | _ ->
        None

let sub_bind_spec bind_spec =
  match bind_spec with
    | NoSpec | Rec _ ->
        NoSpec

    | Arg name | Dec name ->
        Dec name

let rec bind_spec gamma exp =
  match exp with
    | EProj (_, _, arg) ->
        sub_bind_spec (bind_spec gamma arg)

    | EVar x ->
        List.assoc_opt x (Type_ctx.all_type gamma)
          |> Option2.map snd
          |> Option2.with_default NoSpec

    | _ ->
        NoSpec

let structurally_decreasing_bind_spec ~head_spec ~arg_spec =
  match (head_spec, arg_spec) with
    | (Rec rec_name, Dec dec_name) ->
        String.equal rec_name dec_name

    | (Rec _, _) ->
        false

    | _ ->
        true

let structurally_decreasing gamma ~head ~arg =
  structurally_decreasing_bind_spec
    ~head_spec:(bind_spec gamma head)
    ~arg_spec:(bind_spec gamma arg)

let matches_dec annot bind_spec =
  match annot with
    | Some f ->
        structurally_decreasing_bind_spec
          ~head_spec:(Rec f)
          ~arg_spec:bind_spec

    | None ->
        true

let ignore_binding (s : string) : bool =
  String.length s > 0 && Char.equal (String.get s 0) '_'

(* Type checking *)

let rec substitute : before:string -> after:typ -> typ -> typ =
  fun ~before ~after tau ->
    match tau with
      | TArr (arg, ret) ->
          TArr
            ( substitute ~before ~after arg
            , substitute ~before ~after ret
            )

      | TTuple components ->
          TTuple
            ( List.map
                (substitute ~before ~after)
                components
            )

      | TData name ->
          TData name

      | TForall (a, bound_type) ->
          if String.equal before a then
            tau
          else
            TForall (a, substitute ~before ~after bound_type)

      | TVar x ->
          if String.equal before x then
            after
          else
            tau

type error =
  | VarNotFound of string
  | CtorNotFound of string
  | PatternMatchFailure of typ * pat

  | GotFunctionButExpected of typ
  | GotTupleButExpected of typ
  | GotTypeOperatorButExpected of typ
  | GotButExpected of typ * typ

  | BranchMismatch of typ * (string * typ)

  | CannotInferFunctionType
  | CannotInferCaseType
  | CannotInferHoleType
  | CannotInferTypeOperatorType

  | ExpectedArrowButGot of typ
  | ExpectedTupleButGot of typ
  | ExpectedForallButGot of typ

  | TupleLengthMismatch of typ
  | ProjectionLengthMismatch of typ
  | ProjectionOutOfBounds of int * int

  | TypeOperatorParameterNameMismatch of string * string

  | AssertionTypeMismatch of typ * typ
  [@@deriving yojson]

(* returns return type * arg type *)
let ctor_info :
 exp -> datatype_ctx -> string -> (typ * typ, exp * error) result =
  fun exp_context sigma ctor_name ->
    Option.to_result
      ~none:(exp_context, CtorNotFound ctor_name)
      ( List2.find_map
          ( fun (type_name, ctors) ->
              List2.find_map
                ( fun (ctor_name', arg_type) ->
                    if String.equal ctor_name ctor_name' then
                      Some (TData type_name, arg_type)
                    else
                      None
                )
                ctors
          )
          sigma
      )

type state =
  { function_decrease_requirement : string option (* TODO: currently unused *)
  ; match_depth : int
  }

let rec check' :
 state ->
 datatype_ctx ->
 type_ctx ->
 exp ->
 typ ->
 (hole_ctx, exp * error) result =
  fun state sigma gamma exp tau ->
    let open Result2.Syntax in
    match exp with
      | EFix (func_name_opt, param_pat, body) ->
          begin match tau with
            | TArr (arg_type, return_type) ->
                let func_name_gamma =
                  Pat.bind_rec_name_typ func_name_opt tau
                in
                let arg_bind_spec =
                  func_name_opt
                    |> Option.map (fun name -> Arg name)
                    |> Option2.with_default NoSpec
                in
                let* param_gamma =
                  Pat.bind_typ arg_bind_spec param_pat arg_type
                    |> Option.to_result
                         ~none:
                           ( exp
                           , PatternMatchFailure (arg_type, param_pat)
                           )
                in
                check'
                  state
                  sigma
                  (Type_ctx.concat [param_gamma; func_name_gamma; gamma])
                  body
                  return_type

            | _ ->
                Error
                  ( exp
                  , GotFunctionButExpected tau
                  )
          end

      | ETuple exps ->
          begin match tau with
            | TTuple taus ->
                if Int.equal (List.length exps) (List.length taus) then
                  List.map2 (check' state sigma gamma) exps taus
                    |> Result2.sequence
                    |> Result.map List.concat
                else
                  Error
                    ( exp
                    , TupleLengthMismatch tau
                    )

            | _ ->
              Error
                ( exp
                , GotTupleButExpected tau
                )
          end

      | ECase (scrutinee, branches) ->
          let* (scrutinee_type, scrutinee_delta) =
            infer' state sigma gamma scrutinee
          in
          let dec_bind_spec =
            scrutinee
              |> bind_spec gamma
              |> sub_bind_spec
          in
          let+ branch_deltas =
            branches
              |> List.map
                   ( fun (ctor_name, (param_pat, body)) ->
                       let* (return_type, arg_type) =
                         ctor_info exp sigma ctor_name
                       in
                       if equal scrutinee_type return_type then
                         let* param_gamma =
                           Pat.bind_typ dec_bind_spec param_pat arg_type
                             |> Option.to_result
                                  ~none:
                                    ( exp
                                    , PatternMatchFailure (arg_type, param_pat)
                                    )
                         in
                         check'
                           { state with
                               match_depth = state.match_depth + 1
                           }
                           sigma
                           (Type_ctx.concat [param_gamma; gamma])
                           body
                           tau
                       else
                         Error
                           ( exp
                           , BranchMismatch
                               ( scrutinee_type
                               , (ctor_name, return_type)
                               )
                           )
                   )
              |> Result2.sequence
              |> Result.map List.concat
          in
            scrutinee_delta @ branch_deltas

      | EHole name ->
          Ok
            [ ( name
              , ( gamma
                , tau
                , state.function_decrease_requirement
                , state.match_depth
                )
              )
            ]

      (* Nonstandard, but useful for let-bindings *)
      | EApp (_, head, ETypeAnnotation (arg, arg_type)) ->
          let* arg_delta =
            check' state sigma gamma arg arg_type
          in
          let+ head_delta =
            check' state sigma gamma head (TArr (arg_type, tau))
          in
          head_delta @ arg_delta

      | ETAbs (a, body) ->
          begin match tau with
            | TForall (a', bound_type) ->
                if not (String.equal a a') then
                  Error
                    ( exp
                    , TypeOperatorParameterNameMismatch (a, a')
                    )
                else
                  let param_gamma =
                    Type_ctx.add_poly a Type_ctx.empty
                  in
                  check'
                    state
                    sigma
                    (Type_ctx.concat [param_gamma; gamma])
                    body
                    bound_type

            | _ ->
                Error
                  ( exp
                  , GotTypeOperatorButExpected tau
                  )
          end

      | EApp (_, _, _)
      | EVar _
      | EProj (_, _, _)
      | ECtor (_, _)
      | EAssert (_, _)
      | ETypeAnnotation (_, _)
      | ETApp (_, _) ->
          let* (tau', delta) =
            infer' state sigma gamma exp
          in
          if equal tau tau' then
            Ok delta
          else
            Error
              ( exp
              , GotButExpected (tau', tau)
              )

and infer' :
 state ->
 datatype_ctx ->
 type_ctx ->
 exp ->
 (typ * hole_ctx, exp * error) result =
  fun state sigma gamma exp ->
    let open Result2.Syntax in
    match exp with
      | EFix (_, _, _) ->
          Error
            ( exp
            , CannotInferFunctionType
            )

      | EApp (_, head, arg) ->
          let* (head_type, head_delta) =
            infer' state sigma gamma head
          in
          begin match head_type with
            | TArr (arg_type, return_type) ->
                let+ arg_delta =
                  check' state sigma gamma arg arg_type
                in
                (return_type, head_delta @ arg_delta)

            | _ ->
                Error
                  ( exp
                  , ExpectedArrowButGot head_type
                  )
          end

      | EVar name ->
          begin match List.assoc_opt name (Type_ctx.all_type gamma) with
            | Some (tau', _) ->
                Ok (tau', [])

            | None ->
                Error
                  ( exp
                  , VarNotFound name
                  )
          end

      | ETuple exps ->
          exps
            |> List.map (infer' state sigma gamma)
            |> Result2.sequence
            |> Result.map List.split
            |> Result.map
                 ( fun (taus, deltas) ->
                     ( TTuple taus
                     , List.concat deltas
                     )
                 )

      | EProj (n, i, arg) ->
          let* (arg_type, arg_delta) =
            infer' state sigma gamma arg
          in
          begin match arg_type with
            | TTuple components ->
                if Int.equal n (List.length components) then
                  if i <= n then
                    Ok (List.nth components (i - 1), arg_delta)
                  else
                    Error
                      ( exp
                      , ProjectionOutOfBounds (n, i)
                      )
                else
                  Error
                    ( exp
                    , ProjectionLengthMismatch arg_type
                    )

            | _ ->
                Error
                  ( exp
                  , ExpectedTupleButGot arg_type
                  )
          end

      | ECtor (ctor_name, arg) ->
          let* (return_type, arg_type) =
            ctor_info exp sigma ctor_name
          in
          let+ arg_delta =
            check' state sigma gamma arg arg_type
          in
          (return_type, arg_delta)

      | ECase (_, _) ->
          Error
            ( exp
            , CannotInferCaseType
            )

      | EHole _ ->
          Error
            ( exp
            , CannotInferHoleType
            )

      | EAssert (left, right) ->
          let* (left_type, left_delta) =
            infer' state sigma gamma left
          in
          let* (right_type, right_delta) =
            infer' state sigma gamma right
          in
          if equal left_type right_type then
            Ok (TTuple [], left_delta @ right_delta)
          else
            Error
              ( exp
              , AssertionTypeMismatch (left_type, right_type)
              )

      | ETypeAnnotation (exp', tau') ->
          let+ delta =
            check' state sigma gamma exp' tau'
          in
          (tau', delta)

      | ETAbs (_, _) ->
          Error
            ( exp
            , CannotInferTypeOperatorType
            )

      | ETApp (head, type_arg) ->
          let* (head_type, head_delta) =
            infer' state sigma gamma head
          in
          begin match head_type with
            | TForall (a, bound_type) ->
                Ok
                  ( substitute ~before:a ~after:type_arg bound_type
                  , head_delta
                  )

            | _ ->
                Error
                  ( exp
                  , ExpectedForallButGot head_type
                  )
          end

let check =
  check'
    { function_decrease_requirement = None
    ; match_depth = 0
    }

let infer =
  infer'
    { function_decrease_requirement = None
    ; match_depth = 0
    }
