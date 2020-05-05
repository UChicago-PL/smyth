open Bark
open Bark.Syntax
open Lang

(* Parser specialization *)

type problem =
  | ExpectingLeftParen
  | ExpectingRightParen
  | ExpectingLeftBracket
  | ExpectingRightBracket
  | ExpectingComma
  | ExpectingRightArrow
  | ExpectingSpace
  | ExpectingPound
  | ExpectingDot
  | ExpectingEquals
  | ExpectingDoubleEquals
  | ExpectingHole
  | ExpectingLambda
  | ExpectingPipe
  | ExpectingColon
  | ExpectingFuncSpec

  | ExpectingWildcard
  | ExpectingLineComment
  | ExpectingMultiCommentStart
  | ExpectingMultiCommentEnd

  | ExpectingExactly of int * int

  | ExpectingMoreIndent

  | ExpectingLet
  | ExpectingIn
  | ExpectingCase
  | ExpectingOf
  | ExpectingType
  | ExpectingAssert

  | ExpectingNat

  | ExpectingConstructorName
  | ExpectingVariableName
  | ExpectingHoleName

  | ExpectingFunctionArity

  | ExpectingTupleSize
  | ExpectingTupleIndex

  | ExpectingName of string * string

  | NegativeArity of int
  | ZeroArity

  | ExpectingEnd
  [@@deriving yojson]

type context =
  | CType
  | CTTuple
  | CTData
  | CTArr
  | CTForall
  | CTVar

  | CPat
  | CPTuple
  | CPVar
  | CPWildcard

  | CExp
  | CELet
  | CEVar
  | CECtor
  | CETuple
  | CEProj
  | CEApp
  | CEHole
  | CELambda
  | CECase
  | CEList
  | CENat

  | CStatement
  | CSDatatype
  | CSDatatypeCtors
  | CSDefinition
  | CSAssertion
  | CSFuncSpec
  | CSFuncSpecInput
  | CSFuncSpecOutput

  | CProgram
  [@@deriving yojson]

type 'a parser =
  (context, problem, 'a) Bark.parser

(* Symbols *)

let left_paren =
  Token ("(", ExpectingLeftParen)

let right_paren =
  Token (")", ExpectingRightParen)

let left_bracket =
  Token ("[", ExpectingLeftBracket)

let right_bracket =
  Token ("]", ExpectingRightBracket)

let comma =
  Token (",", ExpectingComma)

let right_arrow =
  Token ("->", ExpectingRightArrow)

let pound =
  Token ("#", ExpectingPound)

let dot =
  Token (".", ExpectingDot)

let equals =
  Token ("=", ExpectingEquals)

let double_equals =
  Token ("==", ExpectingDoubleEquals)

let hole =
  Token ("??", ExpectingHole)

let lambda =
  Token ("\\", ExpectingLambda)

let pipe =
  Token ("|", ExpectingPipe)

let colon =
  Token (":", ExpectingColon)

let wildcard =
  Token ("_", ExpectingWildcard)

let line_comment_start =
  Token ("--", ExpectingLineComment)

let multi_comment_start =
  Token ("{-", ExpectingMultiCommentStart)

let multi_comment_end =
  Token ("-}", ExpectingMultiCommentEnd)

(* Keywords *)

let forall_keyword =
  Token ("forall", ExpectingLet)

let let_keyword =
  Token ("let", ExpectingLet)

let in_keyword =
  Token ("in", ExpectingIn)

let case_keyword =
  Token ("case", ExpectingCase)

let of_keyword =
  Token ("of", ExpectingOf)

let type_keyword =
  Token ("type", ExpectingType)

let assert_keyword =
  Token ("assert", ExpectingAssert)

(* No-lookahead keywords *)

let specify_function_token =
  Token ("specifyFunction", ExpectingFuncSpec)

(* Parser helpers *)

let optional : 'a parser -> 'a option parser =
  fun p ->
    one_of
      [ map (fun x -> Some x) p
      ; succeed None
      ]

type indent_strictness =
  | Strict
  | Lax

let check_indent : indent_strictness -> unit parser =
  fun indent_strictness ->
    let check_ok col indent =
      match indent_strictness with
        | Strict ->
            col > indent

        | Lax ->
            col >= indent
    in
    let* ok =
      succeed check_ok
        |= get_col
        |= get_indent
    in
    if ok then
      succeed ()
    else
      problem ExpectingMoreIndent

let with_current_indent : 'a parser -> 'a parser =
  fun p ->
    let* col =
      get_col
    in
    with_indent col p

(* Spaces *)

let if_progress : 'a parser -> int -> (int, unit) step parser =
  fun p offset ->
    let+ new_offset =
      succeed (fun n -> n)
        |. p
        |= get_offset
    in
    if Int.equal offset new_offset then
      Done ()
    else
      Loop new_offset

let any_spaces : unit parser =
  loop 0
    ( if_progress
        ( one_of
            [ line_comment line_comment_start
            ; multi_comment multi_comment_start multi_comment_end Nestable
            ; spaces
            ]
        )
    )

(* Indented spaces *)

let sspaces : unit parser =
  succeed ()
    |. any_spaces
    |. check_indent Strict

let lspaces : unit parser =
  succeed ()
    |. any_spaces
    |. check_indent Lax

let tuple : ('a -> 'b) -> ('a list -> 'b) -> 'a parser -> 'b parser =
  fun single multiple item ->
    map
      ( fun inners ->
          match inners with
            | [inner] ->
                single inner

            | _ ->
                multiple inners
      )
      ( sequence
          ~start:left_paren
          ~separator:comma
          ~endd:right_paren
          ~spaces:lspaces
          ~item:item
          ~trailing:Forbidden
      )

let listt : 'a parser -> 'a list parser =
  fun item ->
    sequence
      ~start:left_bracket
      ~separator:comma
      ~endd:right_bracket
      ~spaces:lspaces
      ~item:item
      ~trailing:Forbidden

let exactly : int -> 'a parser -> 'a list parser =
  fun n p ->
    loop (n, [])
      ( fun (k, rev_xs) ->
          if k <= 0 then
            succeed (Done (List.rev rev_xs))
          else
            one_of
              [ map (fun x -> Loop (k - 1, x :: rev_xs)) p
              ; problem (ExpectingExactly (n, n - k))
              ]
      )

let chainl1 : context -> 'a parser -> ('a -> 'a -> 'a) parser -> 'a parser =
  fun chain_context p op ->
    let rec next acc =
      one_of
        [ in_context chain_context
            ( let* combiner =
                op
              in
              p |> and_then (combiner acc >> next)
            )
        ; succeed acc
        ]
    in
    p |> and_then next

let chainr1 : context -> 'a parser -> ('a -> 'a -> 'a) parser -> 'a parser =
  fun chain_context p op ->
    let rec rest acc =
      one_of
        [ in_context chain_context
            ( let* combiner =
                op
              in
              map (combiner acc) (p |> and_then rest)
            )
        ; succeed acc
        ]
    in
    p |> (and_then rest)

let ignore_with : 'a -> unit parser -> 'a parser =
  fun x p ->
    map (fun _ -> x) p

(* Character predicates *)

let inner_char : char -> bool =
  fun c ->
    Char2.lowercase_char c
      || Char2.uppercase_char c
      || Char2.digit_char c
      || Char.equal c '_'

(* Names *)

let reserved_words =
  String_set.of_list
    [ "forall"
    ; "if"; "then"; "else"
    ; "case"; "of"
    ; "let"; "in"
    ; "type"
    ; "module"; "where"
    ; "import"; "exposing"
    ; "as"
    ; "port"
    ; "infix"; "infixl"; "infixr"
    ]

let constructor_name : string parser =
  variable
    ~start:Char2.uppercase_char
    ~inner:inner_char
    ~reserved:String_set.empty
    ~expecting:ExpectingConstructorName

let variable_name : string parser =
  variable
    ~start:Char2.lowercase_char
    ~inner:inner_char
    ~reserved:reserved_words
    ~expecting:ExpectingVariableName

(* Types *)

let rec typ' : unit -> typ parser =
  fun () ->
    let monotype' : unit -> typ parser =
      fun () ->
        let ground_typ : typ parser =
          succeed (fun t -> t)
            |= one_of
                 [ in_context CTTuple
                     ( tuple (fun t -> t) (fun ts -> TTuple ts) (lazily typ')
                     )

                 ; in_context CTData
                     ( map (fun name -> TData name) constructor_name
                     )

                 ; in_context CTVar
                     ( map (fun name -> TVar name) variable_name
                     )
                 ]
            |. any_spaces
        in
        chainr1 CTArr ground_typ
          ( ignore_with (fun domain codomain -> TArr (domain, codomain))
              ( succeed ()
                  |. symbol right_arrow
                  |. any_spaces
              )
          )
    in
    let polytype' : unit -> typ parser =
      fun () ->
        in_context CTForall
          ( succeed (fun a bound_type -> TForall (a, bound_type))
              |. keyword forall_keyword
              |. any_spaces
              |= variable_name
              |. any_spaces
              |. symbol dot
              |. any_spaces
              |= lazily typ'
          )
    in
      one_of
        [ lazily polytype'
        ; lazily monotype'
        ]

let typ : typ parser =
  in_context CType (lazily typ')

(* Patterns *)

let rec pat' : unit -> pat parser =
  fun () ->
    one_of
      [ in_context CPTuple
          ( tuple (fun p -> p) (fun ps -> PTuple ps) (lazily pat')
          )

      ; in_context CPWildcard
          ( ignore_with PWildcard (symbol wildcard)
          )

      ; in_context CPVar
          ( map (fun name -> PVar name) variable_name
          )
      ]

let pat : pat parser =
  in_context CPat (lazily pat')

(* Expressions *)

let rec binding' : unit -> (string * pat list * exp) parser =
  fun () ->
    succeed (fun name pats body -> (name, pats, body))
      |= variable_name
      |. sspaces
      |= loop []
           ( fun rev_patterns ->
               one_of
                 [ succeed (fun p -> Loop (p :: rev_patterns))
                     |= pat
                     |. sspaces
                 ; succeed (Done (List.rev rev_patterns))
                 ]
           )
      |. symbol equals
      |. sspaces
      |= lazily exp'

and definition' : unit -> (typ * string * pat list * exp) parser =
  fun () ->
    let* (name, the_typ) =
        succeed Pair2.pair
          |= backtrackable variable_name
          |. backtrackable any_spaces
          |. symbol colon
          |. any_spaces
          |= typ
    in
    let* (name', pats, body) =
      lazily binding'
    in
    if not (String.equal name name') then
      problem
        ( ExpectingName (name, name')
        )
    else
      succeed
        ( the_typ
        , name
        , pats
        , body
        )

and ground_exp' : unit -> exp parser =
  fun () ->
    let branches =
      loop []
        ( fun rev_branches ->
            one_of
              [ succeed
                 (fun c x body -> Loop ((c, (x, body)) :: rev_branches))
                  |. check_indent Strict
                  |= constructor_name
                  |. sspaces
                  |= one_of
                       [ pat
                       ; succeed (PTuple [])
                       ]
                  |. sspaces
                  |. symbol right_arrow
                  |. sspaces
                  |= lazily exp'
                  |. any_spaces
              ; succeed (Done (List.rev rev_branches))
              ]
        )
    in
    (* TODO Support more than just fix! *)
    one_of
      [ in_context CELet
          ( succeed
             ( fun (typ, name, pats, body) rest ->
                  Desugar.lett
                    typ
                    name
                    (Desugar.func_args pats body)
                    rest
             )
              |. keyword let_keyword
              |. sspaces
              |= lazily definition'
              |. lspaces
              |. keyword in_keyword
              |. lspaces
              |= lazily exp'
          )

      ; in_context CECase
          ( succeed (fun scrutinee branches -> ECase (scrutinee, branches))
              |. keyword case_keyword
              |. sspaces
              |= lazily exp'
              |. lspaces
              |. keyword of_keyword
              |. sspaces
              |= branches
          )

        (* Constructors handled in post-processing *)
      ; map (fun name -> EVar name)
          ( one_of
              [ in_context CEVar variable_name
              ; in_context CECtor constructor_name
              ]
          )

      ; in_context CETuple
          ( tuple (fun e -> e) (fun es -> ETuple es) (lazily exp')
          )

      ; in_context CEProj
          ( succeed (fun n i arg -> EProj (n, i, arg))
              |. symbol pound
              |= Bark.int ExpectingTupleSize
              |. symbol dot
              |= Bark.int ExpectingTupleIndex
              |. sspaces
              |= lazily ground_exp'
          )

      ; in_context CEHole
          ( ignore_with (EHole Fresh.unused)
              (symbol hole)
              (* Don't allow user hole names (so each hole name appears at most
               * once in a program)
               *)
          )

      ; in_context CELambda
         ( succeed (fun param body -> EFix (None, param, body))
             |. symbol lambda
             |. sspaces
             |= pat
             |. sspaces
             |. symbol right_arrow
             |. sspaces
             |= lazily exp'
         )

      ; in_context CEList
          ( map Desugar.listt
              (listt (lazily exp'))
          )

      ; in_context CENat
          ( map Desugar.nat
              (Bark.int ExpectingNat)
          )
      ]

and exp' : unit -> exp parser =
  fun () ->
    with_current_indent
      ( chainl1 CEApp (with_current_indent (lazily ground_exp'))
          ( ignore_with (fun head arg -> EApp (false, head, arg))
              (backtrackable sspaces)
          )
      )

let ground_exp : exp parser =
  in_context CExp (lazily ground_exp')

let exp : exp parser =
  in_context CExp (lazily exp')

let definition : (typ * string * pat list * exp) parser =
  lazily definition'

(* Programs *)

let specify_function_name : int parser =
  let* arity =
    succeed (fun n -> n)
      (* Important: must be token (not keyword) so no lookahead! *)
      |. token specify_function_token
      |= one_of
           [ Bark.int ExpectingFunctionArity
           ; succeed 1
           ]
  in
  if arity < 0 then
    problem (NegativeArity arity)
  else if arity = 0 then
    problem ZeroArity
  else
    succeed arity

type statement =
  | Datatype of (string * (string * typ) list)
  | Definition of (string * typ * exp)
  | Assertion of (exp * exp)

let statement_group : statement list parser =
  in_context CStatement
    ( one_of
        [ in_context CSDatatype
            ( succeed (fun data_name ctors -> [Datatype (data_name, ctors)])
                |. keyword type_keyword
                |. sspaces
                |= constructor_name
                |. sspaces
                |. symbol equals
                |. sspaces
                |= chainr1 CSDatatypeCtors
                     ( succeed (fun ctor_name arg -> [(ctor_name, arg)])
                         |= constructor_name
                         |. sspaces
                         |= one_of
                              [ typ
                              ; succeed (TTuple [])
                              ]
                     )
                     ( ignore_with List.append
                         ( succeed ()
                             |. symbol pipe
                             |. sspaces
                         )
                     )
            )

        ; in_context CSAssertion
            ( succeed (fun e1 e2 -> [Assertion (e1, e2)])
                |. keyword assert_keyword
                |= exp
                |. sspaces
                |. symbol double_equals
                |. sspaces
                |= exp
            )

        ; in_context CSFuncSpec
            ( let* (arity, func) =
                succeed (fun n f -> (n, f))
                  |= specify_function_name
                  |. sspaces
                  |= ground_exp
                  |. sspaces
              in
              let+ io_examples =
                listt
                  ( succeed (fun inputs output -> (inputs, output))
                      |. symbol left_paren
                      |= exactly arity
                           ( in_context CSFuncSpecInput
                               ( succeed (fun e -> e)
                                   |. lspaces
                                   |= exp
                                   |. lspaces
                                   |. symbol comma
                               )
                           )
                      |. lspaces
                      |= in_context CSFuncSpecOutput exp
                      |. symbol right_paren
                  )
              in
              List.map
                ( fun (inputs, output) ->
                    Assertion
                      ( Desugar.app func inputs
                      , output
                      )
                )
                io_examples
            )

        ; in_context CSDefinition
            ( let+ (typ, name, pats, body) =
                definition
              in
              [ Definition
                  ( name
                  , typ
                  , Desugar.func_args pats body
                  )
              ]
            )
        ]
    )

let program : Desugar.program parser =
  in_context CProgram
    ( loop []
        ( fun rev_statements ->
            one_of
              [ succeed
                 ( fun stmts ->
                     Loop (List.rev_append stmts rev_statements)
                 )
                  |= statement_group
                  |. any_spaces

              ; succeed
                 ( fun main_opt ->
                     Done
                       ( let open Desugar in
                         List.fold_left
                           ( fun prog stmt ->
                               match stmt with
                                 | Datatype d ->
                                     { prog with
                                         datatypes = d :: prog.datatypes
                                     }

                                 | Definition d ->
                                     { prog with
                                         definitions = d :: prog.definitions
                                     }

                                 | Assertion a ->
                                     { prog with
                                         assertions = a :: prog.assertions
                                     }
                           )
                           { datatypes = []
                           ; definitions = []
                           ; assertions = []
                           ; main_opt = main_opt
                           }
                           rev_statements
                       )
                 )
                  |= optional exp
                  |. any_spaces
                  |. endd ExpectingEnd
              ]
        )
    )
