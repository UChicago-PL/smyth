open Lang

val rank :
  (hole_name * exp) list -> int

val sort :
  (hole_name * exp) list list -> (hole_name * exp) list list

val first_recursive :
  (hole_name * exp) list list -> (hole_name * exp) list option
