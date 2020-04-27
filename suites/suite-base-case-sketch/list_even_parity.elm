type Boolean
  = T ()
  | F ()

type BooleanList
  = Nil ()
  | Cons (Boolean, BooleanList)

evenParity : BooleanList -> Boolean
evenParity xs =
  case xs of
    Nil _ ->
      T ()

    Cons p ->
      ??
