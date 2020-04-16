open Bark
open Bark.Syntax
open Lang

(* Parser specialization *)

type problem =
  | ExpectingLeftParen
  | ExpectingRightParen
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

  | ExpectingMoreIndent

  | ExpectingLet
  | ExpectingIn
  | ExpectingCase
  | ExpectingOf
  | ExpectingType
  | ExpectingAssert

  | ExpectingConstructorName
  | ExpectingVariableName

  | ExpectingTupleSize
  | ExpectingTupleIndex

  | ExpectingName of string

  | ExpectingEnd

type context =
  | CType
  | CTTuple
  | CTData
  | CTArr

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

  | CStatement
  | CSDatatype
  | CSDatatypeCtors
  | CSDefinition
  | CSAssertion

  | CProgram

type 'a parser =
  (context, problem, 'a) Bark.parser

(* Symbols *)

let left_paren =
  Token ("(", ExpectingLeftParen)

let right_paren =
  Token (")", ExpectingRightParen)

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

(* Keywords *)

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

(* Indented spaces *)
let sspaces : unit parser =
  succeed ()
    |. spaces
    |. check_indent Strict

let lspaces : unit parser =
  succeed ()
    |. spaces
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

let uppercase_char : char -> bool =
  function
    | 'A' .. 'Z' -> true
    | _ -> false

let lowercase_char : char -> bool =
  function
    | 'a' .. 'z' -> true
    | _ -> false

let digit_char : char -> bool =
  function
    | '0' .. '9' -> true
    | _ -> false

let inner_char : char -> bool =
  fun c ->
    lowercase_char c || uppercase_char c || digit_char c || c = '_'

(* Names *)

let reserved_words =
  String_set.of_list
    [ "if"; "then"; "else"
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
    ~start:uppercase_char
    ~inner:inner_char
    ~reserved:String_set.empty
    ~expecting:ExpectingConstructorName

let variable_name : string parser =
  variable
    ~start:(fun c -> lowercase_char c || c = '_')
    ~inner:inner_char
    ~reserved:reserved_words
    ~expecting:ExpectingVariableName

(* Types *)

let rec typ' : unit -> typ parser =
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
             ]
        |. spaces
    in
    chainr1 CTArr ground_typ
      ( ignore_with (fun domain codomain -> TArr (domain, codomain))
          ( succeed ()
              |. symbol right_arrow
              |. spaces
          )
      )

let typ : typ parser =
  in_context CType (typ' ())

(* Expressions *)

let placeholder_hole_name : hole_name =
  -1

let rec exp' : unit -> exp parser =
  fun () ->
    let branches =
      loop []
        ( fun rev_branches ->
            one_of
              [ succeed
                 (fun c xs body -> Loop ((c, (xs, body)) :: rev_branches))
                  |. check_indent Strict
                  |= constructor_name
                  |. sspaces
                  |= one_of
                       [ tuple (fun x -> [x]) (fun xs -> xs) variable_name
                       ; map (fun x -> [x]) variable_name
                       ]
                  |. sspaces
                  |. symbol right_arrow
                  |. sspaces
                  |= lazily exp'
                  |. spaces
              ; succeed (Done (List.rev rev_branches))
              ]
        )
    in
    let rec ground_exp : unit -> exp parser =
      fun () ->
        one_of
          [ in_context CELet
              ( succeed Desugar.lett
                  |. keyword let_keyword
                  |. sspaces
                  |= variable_name
                  |. sspaces
                  |. symbol equals
                  |. sspaces
                  |= lazily exp'
                  |. lspaces
                  |. keyword in_keyword
                  |. lspaces
                  |= lazily exp'
              )

          ; in_context CECase
              ( succeed Desugar.case
                  |. keyword case_keyword
                  |. sspaces
                  |= lazily exp'
                  |. lspaces
                  |. keyword of_keyword
                  |. sspaces
                  |= branches
              )

          ; in_context CEVar
              ( map (fun name -> EVar name) variable_name
              )

          ; in_context CECtor
              ( succeed (fun name arg -> ECtor (name, arg))
                  |= constructor_name
                  |. sspaces
                  |= lazily ground_exp
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
                  |= lazily ground_exp
              )

          ; in_context CEHole
              ( succeed (EHole placeholder_hole_name)
                  |. symbol hole
              )

          ; in_context CELambda
             ( succeed (fun param body -> EFix (None, param, body))
                 |. symbol lambda
                 |. sspaces
                 |= variable_name
                 |. sspaces
                 |. symbol right_arrow
                 |. sspaces
                 |= lazily exp'
             )
          ]
    in
    with_current_indent
      ( chainl1 CEApp (with_current_indent (ground_exp ()))
          ( ignore_with (fun head arg -> EApp (false, head, arg))
              (backtrackable sspaces)
          )
      )

let exp : exp parser =
  in_context CExp (exp' ())

(* Programs *)

type statement =
  | Datatype of (string * (string * typ) list)
  | Definition of (string * typ * exp)
  | Assertion of (exp * exp)

let statement : statement parser =
  in_context CStatement
    ( one_of
        [ in_context CSDatatype
            ( succeed (fun data_name ctors -> Datatype (data_name, ctors))
                |. keyword type_keyword
                |. sspaces
                |= constructor_name
                |. sspaces
                |. symbol equals
                |= chainr1 CSDatatypeCtors
                     ( succeed (fun ctor_name arg -> [(ctor_name, arg)])
                         |= constructor_name
                         |. sspaces
                         |= typ
                     )
                     ( ignore_with List.append
                         ( succeed ()
                             |. symbol pipe
                             |. sspaces
                         )
                     )
            )

        ; in_context CSAssertion
            ( succeed (fun e1 e2 -> Assertion (e1, e2))
                |. keyword assert_keyword
                |= exp
                |. sspaces
                |. symbol double_equals
                |. sspaces
                |= exp
            )

        ; in_context CSDefinition
            ( let* (name, the_typ) =
                succeed Pair2.pair
                  |= backtrackable variable_name
                  |. backtrackable spaces
                  |. symbol colon
                  |. spaces
                  |= typ
              in
              succeed (fun the_exp -> Definition (name, the_typ, the_exp))
                |. keyword (Token (name, ExpectingName name))
                |. sspaces
                |. symbol equals
                |. sspaces
                |= exp
            )
        ]
    )

let program : Desugar.program parser =
  in_context CProgram
    ( loop []
        ( fun rev_statements ->
            one_of
              [ succeed (fun stmt -> Loop (stmt :: rev_statements))
                  |= statement
                  |. spaces

              ; succeed
                 ( fun main_opt ->
                     Done
                       ( let open Desugar in
                         List.fold_right
                           ( fun stmt prog ->
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
                           rev_statements
                           { datatypes = []
                           ; definitions = []
                           ; assertions = []
                           ; main_opt = main_opt
                           }
                       )
                 )
                  |= optional exp
                  |. spaces
                  |. endd ExpectingEnd
              ]
        )
    )
