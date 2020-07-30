(*s: semgrep/core/Flag_semgrep.ml *)
(*s: constant [[Flag_semgrep.verbose]] *)
(* unused for now *)
let _verbose = ref false
(*e: constant [[Flag_semgrep.verbose]] *)

let debug = ref false

(*s: constant [[Flag_semgrep.debug]] *)
(* note that this will stop at the first fail(), but if you restrict
 * enough your pattern, this can help you debug your problem.*)
let debug_matching = ref false
(*e: constant [[Flag_semgrep.debug]] *)
(*s: constant [[Flag_semgrep.debug_with_full_position]] *)
let debug_with_full_position = ref false
(*e: constant [[Flag_semgrep.debug_with_full_position]] *)

(* !experimental: a bit hacky, and may introduce big perf regressions! *)

(*s: constant [[Flag_semgrep.go_deeper_expr]] *)
(* should be used with DeepEllipsis; do it implicitely has issues *)
let go_deeper_expr = ref true
(*e: constant [[Flag_semgrep.go_deeper_expr]] *)
(*s: constant [[Flag_semgrep.go_deeper_stmt]] *)
(* this ultimately should go away once '...' works on the CFG *)
let go_deeper_stmt = ref true
(*e: constant [[Flag_semgrep.go_deeper_stmt]] *)
(*s: constant [[Flag_semgrep.go_really_deeper_stmt]] *)
(* not sure we want that ... *)
let go_really_deeper_stmt = ref true
(*e: constant [[Flag_semgrep.go_really_deeper_stmt]] *)

(*s: constant [[Flag_semgrep.equivalence_mode]] *)
(* special mode to set before using generic_vs_generic to match
 * code equivalences.
 *)
let equivalence_mode = ref false
(*e: constant [[Flag_semgrep.equivalence_mode]] *)
(*e: semgrep/core/Flag_semgrep.ml *)
