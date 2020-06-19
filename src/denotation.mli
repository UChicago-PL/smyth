open Smyth
open Lang

type 'a t =
  ('a -> exp) * typ

val bool : bool t

val int : int t

val var : string t

val opt : 'a t -> 'a option t

val list : 'a t -> 'a list t

val nested_list : 'a t -> 'a list list t

val tree : 'a t -> 'a Tree2.t t

val args2 : 'a1 t -> 'a2 t -> ('a1 * 'a2) t

val args3 : 'a1 t -> 'a2 t -> 'a3 t -> ('a1 * 'a2 * 'a3) t

val mono : 'a t -> 'a -> exp

val poly : 'a t -> 'a -> exp
