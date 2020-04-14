open Bark
open Lang

(* Parser specialization *)

type problem =
  | ExpectingLeftParen
  | ExpectingRightParen
  | ExpectingComma
  | ExpectingRightArrow

  | ExpectingConstructorName

type context =
  unit

type 'a parser =
  (context, problem, 'a) Bark.parser

let left_paren =
  Token ("(", ExpectingLeftParen)

let right_paren =
  Token (")", ExpectingRightParen)

let comma =
  Token (",", ExpectingComma)

let right_arrow =
  Token ("->", ExpectingRightArrow)

(* Parser helpers *)

let optional : 'a parser -> 'a option parser =
  fun p ->
    one_of
      [ map (fun x -> Some x) p
      ; succeed None
      ]

(* Character predicates *)

let uppercase_char : char -> bool =
  function
    | 'A' .. 'Z' -> true
    | _ -> false

let lowercase_char : char -> bool =
  function
    | 'a' .. 'z' -> true
    | _ -> false

let _digit_char : char -> bool =
  function
    | '0' .. '9' -> true
    | _ -> false

(* Constructors *)

let constructor : string parser =
  variable
    ~start:uppercase_char
    ~inner:(fun c -> lowercase_char c || uppercase_char c)
    ~reserved:String_set.empty
    ~expecting:ExpectingConstructorName

(* Types *)

let rec typ' : unit -> typ parser =
  fun () ->
    let ground_typ : typ parser =
      one_of
        [ (* Tuple *)
          map
            ( fun inner_types ->
                match inner_types with
                  | [inner_type] ->
                      inner_type

                  | _ ->
                      TTuple inner_types
            )
            ( sequence
                ~start:left_paren
                ~separator:comma
                ~endd:right_paren
                ~spaces:spaces
                ~item:(lazily typ')
                ~trailing:Forbidden
            )

          (* Data *)
        ; map (fun s -> TData s) constructor
        ]
    in
    succeed
      ( fun domain codomain_opt ->
          match codomain_opt with
            | None ->
                domain

            | Some codomain ->
                TArr (domain, codomain)
      )
      |= ground_typ
      |. spaces
      |= optional
           ( succeed (fun codomain -> codomain)
               |. symbol right_arrow
               |. spaces
               |= lazily typ'
               |. spaces
           )

let typ =
  typ' ()

(* Expressions *)

let exp =
  one_of []

(* Programs *)

type program =
  { datatypes : datatype_ctx
  ; bindings : string * (typ * exp) list
  ; assertions : exp * exp list
  ; main : exp option
  }

let program =
  one_of []
