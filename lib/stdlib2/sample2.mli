type 'a gen =
  unit -> 'a

val nat : int gen

val bool : bool gen

val nat_list : int list gen

val nested_nat_list : int list list gen

val bool_list : bool list gen

val net_tree : int Tree2.t gen

val bool_tree : bool Tree2.t gen

val trial :
  int ->
  int ->
  ('a -> 'b) ->
  'a gen ->
  'a gen option ->
  ('a * 'b) list list
