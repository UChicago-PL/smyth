open Lang

val syntactically_equal : pat -> pat -> bool

val bind_res : pat -> res -> env option
val bind_rec_name_res : string option -> res -> env

val bind_typ : bind_spec -> pat -> typ -> type_ctx option
val bind_rec_name_typ : string option -> typ -> type_ctx
