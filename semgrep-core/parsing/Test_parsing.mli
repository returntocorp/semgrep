
val test_parse_lang: bool -> string ->
  (Common.filename list -> Common.filename list) -> Common.filename list ->
  unit

val dump_tree_sitter_cst: Common.filename -> unit
