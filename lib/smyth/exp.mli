open Lang

val syntactically_equal : exp -> exp -> bool

val largest_hole : exp -> hole_name

val has_special_recursion : exp -> bool

val fill_hole : (hole_name * exp) -> exp -> exp
