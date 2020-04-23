open Lang

val sort :
  (hole_name * exp) list list -> (hole_name * exp) list list

val first_recursive :
  (hole_name * exp) list list -> (hole_name * exp) list option
