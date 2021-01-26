(*
   Decorate a pattern and target ASTs to make the suitable for memoization
   during matching.
*)

(*
   These functions set the fields that are required for
   semgrep matching with memoization. This is one-time initialization.
   These fields will not be mutated during the matching process.
*)
val prepare_pattern : AST_generic.any -> unit

(* Exposes just the special-purpose types required to create the cache key. *)
module Cache_key : sig
  type function_id = Match_deep | Match_list
  type list_kind = Original | Flattened
end

module Cache : sig
  type 'a t

  type pattern = AST_generic.stmt list
  type target = AST_generic.stmt list

  val create : unit -> 'a t

  (*
     Match a pattern list against a statement list, using the cache and
     the provided match function.

     'compute' is the function that the cache memoizes.
     It is the user's responsibility to always use the same
     'compute' function with a given 'function_id'.
  *)
  val match_stmt_list :
    get_span_field:('acc -> Stmts_match_span.t) ->
    set_span_field:('acc -> Stmts_match_span.t -> 'acc) ->
    get_mv_field:('acc -> Metavariable.Env.t) ->
    set_mv_field:('acc -> Metavariable.Env.t -> 'acc) ->
    cache: 'acc list t ->
    function_id: Cache_key.function_id ->
    list_kind: Cache_key.list_kind ->
    less_is_ok: bool ->
    compute:(pattern -> target -> 'acc -> 'acc list) ->
    pattern: pattern ->
    target_head: AST_generic.stmt -> (* first stmt of target *)
    target: target option Lazy.t ->
    'acc -> 'acc list
end

val print_stats : unit -> unit
