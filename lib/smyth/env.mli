open Lang

val empty : env

val all_res : env -> (string * res) list
val all_type : env -> (string * typ) list

val concat : env list -> env

val add_res : string * res -> env -> env
val concat_res : (string * res) list -> env -> env
val add_type : string * typ -> env -> env
val concat_type : (string * typ) list -> env -> env
