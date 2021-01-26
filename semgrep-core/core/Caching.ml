(*
   Decorate a pattern and target ASTs to make the suitable for memoization
   during matching.
*)

module MV = Metavars_generic

open Printf
open AST_generic

let debug = false

(* A set of metavariables. Access cost is O(log n). *)
module Names = AST_generic.String_set

(* Count the number of occurrences of each backreference of a metavariable. *)
module Name_counts = Map.Make (String)

let print_names oc names =
  List.iter (fun s -> fprintf oc "  %s\n" s) (Set_.elements names)

let print_name_counts oc name_counts =
  List.iter
    (fun (s, n) -> fprintf oc "  %s: %i\n" s n)
    (Name_counts.bindings name_counts)

let add_one k name_counts =
  match Name_counts.find_opt k name_counts with
  | None -> Name_counts.add k 1 name_counts
  | Some n -> Name_counts.add k (n + 1) name_counts

let get_count k name_counts =
  match Name_counts.find_opt k name_counts with
  | None -> 0
  | Some n -> n

let diff_count k ~new_counts ~old_counts =
  let n = get_count k new_counts - get_count k old_counts in
  assert (n >= 0);
  n

let diff_backrefs bound_metavars ~new_backref_counts ~old_backref_counts =
  let not_backrefs_in_rest_of_pattern =
    Set_.fold (fun k acc ->
      let added_backref_count =
        diff_count k
          ~new_counts:new_backref_counts
          ~old_counts:old_backref_counts
      in
      match added_backref_count with
      | 0 -> Set_.add k acc
      | _ -> acc
    ) bound_metavars Set_.empty
  in
  Set_.diff bound_metavars not_backrefs_in_rest_of_pattern

(*
   During matching a pattern node against a program node, we consult
   a cache to see if we already have run this before and return the
   cached result. This is memoization.

   A cache key is formed from the contents of the pattern node,
   the program node, and all the environment that is sufficient to determine
   the result of the computation. The environment includes the set
   of bound metavariables that are referenced in the rest of the pattern.
   For this, it is correct to use all the bound metavariables rather than the
   ones that really needed. However, this reduces caching efficiency by having
   irrelevant parts of the environment, the unused metavariables, in the cache
   key.

   This function decorates the pattern AST with the set of metavariables
   that are used in the rest of the pattern. This set is consulted at runtime
   to determine whether a captured metavariable should go into the cache key.
*)
let prepare_pattern any =
  let bound_metavars = ref Set_.empty in
  let backref_counts = ref Name_counts.empty in
  let add_metavar name =
    if Set_.mem name !bound_metavars then
      backref_counts := add_one name !backref_counts
    else
      bound_metavars := Set_.add name !bound_metavars
  in
  (*
     This is the list of actions to run in reverse order of the original
     traversal of statements.
  *)
  let stack = ref [] in
  let add_to_stack f = stack := f :: ! stack in

  let visitor = Visitor_AST.mk_visitor {
    Visitor_AST.default_visitor with
    kident = (fun (_k, _) (id, _tok) ->
      if debug then
        printf "kident %s\n" id;
      if Metavars_generic.is_metavar_name id then
        add_metavar id
    );

    kstmt = (fun (k, _) stmt ->
      let stmt_id = (stmt.s_id :> int) in
      if debug then
        printf "kstmt %i\n" stmt_id;

      (* compare the number of backreferences encountered before and after
         visiting the rest of the pattern, so as to determine the set
         of metavariables occurring in the rest of the pattern. *)
      let pre_bound_metavars = !bound_metavars in
      let pre_backref_counts = !backref_counts in
      add_to_stack (fun () ->
        let post_backref_counts = !backref_counts in
        let backrefs =
          diff_backrefs
            pre_bound_metavars
            ~new_backref_counts: post_backref_counts
            ~old_backref_counts: pre_backref_counts
        in
        (*
           It happens that the same stmt can be visited multiple times, to
           the following assertion doesn't hold:

             assert (stmt.s_backrefs = None);
        *)
        stmt.s_backrefs <- Some backrefs;

        if debug then (
          printf "stmt %i\n" stmt_id;
          printf "$A backrefs before %i, after %i\n"
            (get_count "$A" pre_backref_counts)
            (get_count "$A" post_backref_counts);
          printf "bound metavariables:\n%a" print_names pre_bound_metavars;
          printf "pre backref counts:\n%a"
            print_name_counts pre_backref_counts;
          printf "post backref counts:\n%a"
            print_name_counts post_backref_counts;
          printf "backrefs:\n%a" print_names backrefs;
          printf "\n"
        )
      );
      (* continue scanning the current subtree. *)
      k stmt
    );
  } in
  visitor any;
  List.iter (fun f -> f ()) !stack;
  if debug then
    printf "pattern AST:\n%s\n" (AST_generic.show_any any)

module Cache_key = struct
  type env = Metavars_generic.metavars_binding [@@deriving show]
  type function_id = Match_deep | Match_list
  type list_kind = Original | Flattened

  (*
     A cache key. It must unambiguously identify the computation being
     performed. The 'equal' and 'hash' functions must take all these
     fields into account.
  *)
  type t = {
    (* captured values referenced by metavariables in the rest of the
       pattern *)
    min_env: env;

    (* the name of the function being called.*)
    function_id: function_id;

    (* distinguish between stmt lists found in the AST from stmt lists
       resulting from flattening, since both can start with the same stmt
       whose ID is used to identify the list. *)
    list_kind: list_kind;

    (* a match option *)
    less_is_ok: bool;

    (* identifier of the list of stmts in the pattern AST, which is the
       ID of the first stmt of the list. *)
    pattern_stmt_id: Node_ID.t;

    (* identifier of the list of stmts in the target AST, which is the
       ID of the first stmt of the list. Disambiguated by 'list_kind'. *)
    target_stmt_id: Node_ID.t;
  }

  let show_compact k =
    sprintf "%s %s %s %B %i %i"
      (show_env k.min_env)
      (match k.function_id with Match_deep -> "deep" | Match_list -> "list")
      (match k.list_kind with Original -> "orig" | Flattened -> "flat")
      k.less_is_ok
      (k.pattern_stmt_id :> int)
      (k.target_stmt_id :> int)

  (* debugging.
     More calls to 'equal' than to 'hash' indicate frequent collisions. *)
  let hash_calls = ref 0
  let equal_calls = ref 0

  let equal : t -> t -> bool =
    fun a b ->
    incr equal_calls;
    a.pattern_stmt_id = b.pattern_stmt_id
    && a.target_stmt_id = b.target_stmt_id
    && a.function_id = b.function_id
    && a.list_kind = b.list_kind
    && a.less_is_ok = b.less_is_ok
    && Metavars_generic.Referential.equal_metavars_binding
      a.min_env b.min_env

  (* Combine two hashes into one. *)
  let ( ++ ) a b =
    a + 97 * b

  let hash (k : t) =
    incr hash_calls;
    (k.pattern_stmt_id :> int) ++
    (k.target_stmt_id :> int) ++
    Hashtbl.hash k.function_id ++
    Hashtbl.hash k.list_kind ++
    Hashtbl.hash k.less_is_ok ++
    (Metavars_generic.Referential.hash_metavars_binding k.min_env)
end

module Cache = struct
  module Tbl = Hashtbl.Make (Cache_key)
  type 'a t = 'a Tbl.t

  type pattern = AST_generic.stmt list
  type target = AST_generic.stmt list

  let create () = Tbl.create 1000

  (* debugging *)
  let cache_hits = ref 0
  let cache_misses = ref 0

  (*
     The cached result is not completely applicable out of context.
     The variables that were set in the original environment before
     the cached call but are not used in the remaining pattern
     (i.e. not in min_env or in the cache key) existed in the cached result
     but are invalid in other contexts.

     Sample pattern: $A; $B;
                         ^ call the match function here
     Before the call:
       full_env contains $A
       min_env contains nothing
     After the call:
       full_env contains $A (from fresh computation or from cache), $B
       min_env contains nothing or $B, depending if it was updated

     Actions:
       In full_env returned from the cache, all the values of the original
       full_env that weren't set in min_env (or in the backrefs field
       of the pattern) must be injected into the full_env from the cache.
       min_env doesn't need to be updated because it's part of the cache
       key and its new value out the cache can be reused.

     The value bound to $A must be set to the one before the call, not the
     one obtained from the cache.
  *)
  let patch_result_from_cache
      ~get_span_field
      ~set_span_field
      ~get_mv_field
      ~set_mv_field
      backrefs
      current_stmt
      orig_acc
      cached_acc =
    let orig_env : MV.Env.t = get_mv_field orig_acc in
    let cached_env : MV.Env.t = get_mv_field cached_acc in
    let orig_span : Stmts_match_span.t = get_span_field orig_acc in
    let cached_span : Stmts_match_span.t = get_span_field cached_acc in

    let patched_full_env =
      List.map (fun ((k, _v) as cached_binding) ->
        if MV.Env.has_backref k backrefs (* = is in min_env *) then
          cached_binding
        else
          match MV.Env.get_capture k orig_env with
          | None -> (* wasn't bound before the call *) cached_binding
          | Some orig_v -> (* to be restored *) (k, orig_v)
      ) cached_env.full_env
    in
    let patched_env = {
      cached_env with
      full_env = patched_full_env
    } in

    let patched_span : Stmts_match_span.t =
      match orig_span, cached_span with
      | Empty, Empty -> Empty
      | Empty, Span x -> Span { x with left_stmts = [current_stmt] }
      | Span x, Empty -> Span x
      | Span {left_stmts; _}, Span {right_stmts; _} ->
          Span { left_stmts; right_stmts }
    in
    let acc = set_mv_field cached_acc patched_env in
    set_span_field acc patched_span

  let print_cache_access k opt_res =
    printf "access %s %s\n"
      (match opt_res with None -> "*" | Some _ -> " ")
      (Cache_key.show_compact k)

  let match_stmt_list
      ~get_span_field
      ~set_span_field
      ~get_mv_field
      ~set_mv_field
      ~(cache : _ list t)
      ~function_id
      ~list_kind
      ~less_is_ok
      ~compute
      ~(pattern : pattern)
      ~target_head
      ~(target : target option Lazy.t)
      acc =
    match pattern with
    | [] ->
        (match Lazy.force target with
         | None -> []
         | Some target -> compute pattern target acc
        )
    | a :: _ ->
        let mv : Metavars_generic.Env.t = get_mv_field acc in
        let key : Cache_key.t = {
          min_env = mv.min_env;
          function_id;
          list_kind;
          less_is_ok;
          pattern_stmt_id = a.s_id;
          target_stmt_id = target_head.s_id;
        } in
        let lookup_res = Tbl.find_opt cache key in
        if debug then
          print_cache_access key lookup_res;
        match lookup_res with
        | Some res ->
            incr cache_hits;
            let backrefs =
              match a.s_backrefs with
              | None -> assert false
              | Some x -> x
            in
            (match res with
             | [] -> []
             | res ->
                 List.map (fun cached_acc ->
                   patch_result_from_cache
                     ~get_span_field
                     ~set_span_field
                     ~get_mv_field
                     ~set_mv_field
                     backrefs target_head acc cached_acc
                 ) res
            )
        | None ->
            incr cache_misses;
            let res =
              match Lazy.force target with
              | None -> []
              | Some target -> compute pattern target acc
            in
            Tbl.replace cache key res;
            res
end

let print_stats () =
  printf "cache performance:\n";
  printf "- calls to 'hash': %i, calls to 'equal': %i\n"
    !Cache_key.hash_calls !Cache_key.equal_calls;
  printf "- cache hits: %i, cache misses: %i\n"
    !Cache.cache_hits !Cache.cache_misses
