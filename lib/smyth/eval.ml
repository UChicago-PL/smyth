open Lang

type eval_result =
  (res * resumption_assertions, string) result

type eval_env_result =
  (env * resumption_assertions, string) result

(* Note: fuel gets applied at every application. *)
module FuelLimited = struct
  let rec eval fuel env exp =
    let open Result2.Syntax in
    let* _ =
      Result2.guard "Ran out of fuel" (fuel > 0)
    in
    match exp with
      | EFix (f, x, body) ->
          Ok
            ( RFix (env, f, x, body)
            , []
            )

      | EVar x ->
          begin match List.assoc_opt x env with
            | None ->
                Error ("Variable not found: " ^ x)

            | Some r ->
                Ok (r, [])
          end

      | EHole name ->
          Ok
            ( RHole (env, name)
            , []
            )

      | ETuple comps ->
          comps
            |> List.map (eval fuel env)
            |> Result2.sequence
            |> Result2.map
                 begin fun evals -> evals
                   |> List.split
                   |> Pair2.map_fst (fun rs -> RTuple rs)
                   |> Pair2.map_snd List.concat
                 end

      | ECtor (name, arg) ->
          let+ (r, ks) =
            eval fuel env arg
          in
            ( RCtor (name, r)
            , ks
            )

      | EApp (_, e1, e2) ->
          let* (r1, ks1) =
            eval fuel env e1
          in
          let* (r2, ks2) =
            eval fuel env e2
          in
            begin match r1 with
              | RFix (f_env, f, x, body) ->
                  let f_env_extension =
                      Pat.bind_rec_name_res f r1
                  in
                  let* x_env_extension =
                    Pat.bind_res x r2
                      |> Option.to_result ~none:"Pattern match failed"
                  in
                  let new_env =
                    x_env_extension @ f_env_extension @ f_env
                  in
                    Result2.map
                      (Pair2.map_snd @@ fun ks3 -> ks1 @ ks2 @ ks3)
                      (eval (fuel - 1) new_env body)

              | _ ->
                  Ok
                    ( RApp (r1, r2)
                    , ks1 @ ks2
                    )
            end

      | EProj (n, i, arg) ->
          if i <= 0 then
            Error "Non-positive projection index"
          else if i > n then
            Error "Projection index greater than projection length"
          else
            let* (r_arg, ks_arg) =
              eval fuel env arg
            in
              begin match r_arg with
                | RTuple comps ->
                    if n <> List.length comps then
                      Error "Projection length does not match tuple size"
                    else (* 0 < i <= n = |comps| *)
                      Ok
                        ( List.nth comps (i - 1)
                        , ks_arg
                        )

                | _ ->
                    Ok
                      ( RProj (n, i, r_arg)
                      , ks_arg
                      )
              end

      | ECase (scrutinee, branches) ->
          let* (r0, ks0) =
            eval fuel env scrutinee
          in
            begin match r0 with
              | RCtor (ctor_name, r_arg) ->
                  begin match List.assoc_opt ctor_name branches with
                    | Some (arg_pattern, body) ->
                        let* arg_env_extension =
                          Pat.bind_res arg_pattern r_arg
                            |> Option.to_result ~none:"Pattern match failed"
                        in
                        Result2.map
                          ( Pair2.map_snd @@
                              fun ks_body -> ks0 @ ks_body
                          )
                          ( eval fuel
                              (arg_env_extension @ env)
                              body
                          )

                    | None ->
                        Error
                          ( "Non-exhaustive pattern match, "
                          ^ "could not find constructor '"
                          ^ ctor_name
                          ^ "'"
                          )
                  end

              | _ ->
                  Ok
                    ( RCase (env, r0, branches)
                    , ks0
                    )
            end

      | EAssert (e1, e2) ->
          let* (r1, ks1) =
            eval fuel env e1
          in
          let* (r2, ks2) =
            eval fuel env e2
          in
            begin match Res.consistent r1 r2 with
              | Some ks3 ->
                  Ok
                    ( RTuple []
                    , ks1 @ ks2 @ ks3
                    )

              | None ->
                  Error "Result consistency failure"
            end

      | ETypeAnnotation (e, _) ->
          eval fuel env e

  let rec resume fuel hf res =
    let open Result2.Syntax in
    match res with
      | RHole (env, name) ->
          begin match Hole_map.find_opt name hf with
            | Some binding ->
                let* (r, ks) =
                  eval fuel env binding
                in
                let+ (r', ks') =
                  resume fuel hf r
                in
                  ( r'
                  , ks @ ks'
                  )

            | None ->
                let+ (env', ks) =
                  resume_env fuel hf env
                in
                  ( RHole (env', name)
                  , ks
                  )
          end

      | RFix (env, f, x, body) ->
          let+ (env', ks) =
            resume_env fuel hf env
          in
            ( RFix (env', f, x, body)
            , ks
            )

      | RTuple comps ->
          comps
            |> List.map (resume fuel hf)
            |> Result2.sequence
            |> Result2.map
                 begin fun rs -> rs
                   |> List.split
                   |> Pair2.map_fst (fun rs -> RTuple rs)
                   |> Pair2.map_snd List.concat
                 end

      | RCtor (name, arg) ->
          let+ (arg', ks) =
            resume fuel hf arg
          in
            ( RCtor (name, arg')
            , ks
            )

      | RApp (r1, r2) ->
          let* (r1', ks1) =
            resume fuel hf r1
          in
          let* (r2', ks2) =
            resume fuel hf r2
          in
            begin match r1' with
              | RFix (f_env, f, x, body) ->
                  let f_env_extension =
                      Pat.bind_rec_name_res f r1'
                  in
                  let* x_env_extension =
                    Pat.bind_res x r2'
                      |> Option.to_result ~none:"Pattern match failed"
                  in
                  let new_env =
                    x_env_extension @ f_env_extension @ f_env
                  in
                  let* (r, ks) =
                    eval (fuel - 1) new_env body
                  in
                  let+ (r', ks') =
                    resume (fuel - 1) hf r
                  in
                    ( r'
                    , ks1 @ ks2 @ ks @ ks'
                    )

              | _ ->
                  Ok
                    ( RApp (r1', r2')
                    , ks1 @ ks2
                    )
            end

      | RProj (n, i, arg) ->
          if i <= 0 then
            Error "Non-positive projection index"
          else if i > n then
            Error "Projection index greater than projection length"
          else
            let* (arg', ks_arg) =
              resume fuel hf arg
            in
              begin match arg' with
                | RTuple comps ->
                    if n <> List.length comps then
                      Error "Projection length does not match tuple size"
                    else (* 0 < i <= n = |comps| *)
                      Ok
                        ( List.nth comps (i - 1)
                        , ks_arg
                        )

                | _ ->
                    Ok
                      ( RProj (n, i, arg')
                      , ks_arg
                      )
              end

      | RCase (env, scrutinee, branches) ->
          let* (r0, ks0) =
            resume fuel hf scrutinee
          in
            begin match r0 with
              | RCtor (ctor_name, r_arg) ->
                  begin match List.assoc_opt ctor_name branches with
                    | Some (arg_pattern, body) ->
                        Result2.map
                          ( Pair2.map_snd @@
                              fun ks_body -> ks0 @ ks_body
                          )
                          ( resume fuel hf @@
                              RApp
                                ( RFix (env, None, arg_pattern, body)
                                , r_arg
                                )
                          )

                    | None ->
                        Error
                          ( "Non-exhaustive pattern match, "
                          ^ "could not find constructor '"
                          ^ ctor_name
                          ^ "'"
                          )
                  end

              | _ ->
                  let+ (env', ks_env) =
                    resume_env fuel hf env
                  in
                    ( RCase (env', r0, branches)
                    , ks0 @ ks_env
                    )
            end

      | RCtorInverse (name, arg) ->
          let+ (arg', ks) =
            resume fuel hf arg
          in
            ( RCtorInverse (name, arg')
            , ks
            )

  and resume_env fuel hf env : eval_env_result =
    env
      |> List.map
           begin fun binding -> binding
             |> Pair2.map_snd (resume fuel hf)
             |> Pair2.lift_snd_result
           end
      |> Result2.sequence
      |> Result2.map
           begin fun binding -> binding
             |> List.map (fun (x, (r, ks)) -> ((x, r), ks))
             |> List.split
             |> Pair2.map_snd List.concat
           end
end

let eval env exp =
  Timer.with_timeout_ "eval"
    !Params.max_eval_time
    (FuelLimited.eval !Params.initial_fuel env) exp
    (Error "Evaluation time exceeded")

let resume hf res =
  FuelLimited.resume !Params.initial_fuel hf res
