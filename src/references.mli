type ('i, 'o) reference =
  { function_name : string
  ; k_max : int
  ; d_in : 'i Denotation.t
  ; d_out : 'o Denotation.t
  ; input : 'i Sample2.gen
  ; base_case : 'i Sample2.gen option
  ; poly_args : Smyth.Lang.typ list
  ; func : 'i -> 'o
  }

type 'a reference_projection =
  { proj : 'i 'o . ('i, 'o) reference -> 'a
  }

val all : 'a reference_projection -> (string * 'a) list
