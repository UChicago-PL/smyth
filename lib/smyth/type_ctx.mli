open Lang

val empty : type_ctx

val all_type : type_ctx -> type_binding list
val all_poly : type_ctx -> string list

val concat : type_ctx list -> type_ctx

val add_type : type_binding -> type_ctx -> type_ctx
val concat_type : type_binding list -> type_ctx -> type_ctx
val add_poly : poly_binding -> type_ctx -> type_ctx
val concat_poly : poly_binding list -> type_ctx -> type_ctx

val peel_type : type_ctx -> (type_binding * type_ctx) option

val names : type_ctx -> string list
