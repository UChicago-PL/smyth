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

  | ExpectingLet

  | ExpectingConstructorName
  | ExpectingVariableName

  | ExpectingTupleSize
  | ExpectingTupleIndex

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

let space =
  Token (" ", ExpectingSpace)

let pound =
  Token ("#", ExpectingPound)

let dot =
  Token (".", ExpectingDot)

(* Keywords *)

let let_keyword =
  Token ("let", ExpectingLet)

(* Parser helpers *)

let _optional : 'a parser -> 'a option parser =
  fun p ->
    one_of
      [ map (fun x -> Some x) p
      ; succeed None
      ]

let spaces1 : unit parser =
  succeed ()
    |. token space
    |. spaces

let _spaces_after : 'a parser -> 'a parser =
  fun p ->
    succeed (fun x -> x)
      |= p
      |. spaces

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
          ~spaces:spaces
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
    ~start:lowercase_char
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

let typ =
  in_context CType (typ' ())

(* Expressions *)

let placeholder_hole_name : hole_name =
  -1

let rec exp' : unit -> exp parser =
  fun () ->
    let rec ground_exp : unit -> exp parser =
      fun () ->
        succeed (fun e -> e)
          |= one_of
             [ in_context CELet
                 ( succeed Desugar.lett
                     |. keyword let_keyword
                     |. spaces
                     |= variable_name
                     |. spaces
                     |. symbol equals
                     |. spaces
                     |= lazily exp'
                     |. keyword in_keyword
                     |. spaces
                     |= lazily exp'
                 )
             ; in_context CEVar
                 ( map (fun name -> EVar name) variable_name
                 )

             ; in_context CECtor
                 ( succeed (fun name arg -> ECtor (name, arg))
                     |= constructor_name
                     |. spaces1
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
                     |. spaces1
                     |= lazily ground_exp
                 )

             ; in_context CEHole
                 ( succeed (EHole placeholder_hole_name)
                     |. symbol "??"
                 )
             ]
          |. spaces
    in
    chainl1 CEApp (ground_exp ())
      ( succeed (fun head arg -> EApp (false, head, arg))
      )

let exp =
  in_context CExp (exp' ())

(* Programs *)

type program =
  { datatypes : datatype_ctx
  ; bindings : string * (typ * exp) list
  ; assertions : exp * exp list
  ; main : exp option
  }

let program =
  one_of []
