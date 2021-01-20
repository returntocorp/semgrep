(*s: semgrep/metachecking/Check_rule.ml *)
(*s: pad/r2c copyright *)
(* Yoann Padioleau
 *
 * Copyright (C) 2019-2021 r2c
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
*)
(*e: pad/r2c copyright *)
open Common

open Rule
module E = Error_code

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* Checking the checker (metachecking).
 *
 * The goal of this module is to detect bugs, performance issues, or
 * feature suggestions in semgrep rules.
 *
 * TODO:
 *  - use spacegrep or semgrep itself? but need sometimes to express
 *    rules on the yaml structure and sometimes on the pattern itself
 *    (a bit like in templating languages)
*)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)
type env = Rule.t

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)
let rec visit_old_formula f formula =
  match formula with
  | Pat x | PatNot x | PatInside x | PatNotInside x -> f x
  | PatExtra _ -> ()
  | PatEither xs | Patterns xs -> xs |> List.iter (visit_old_formula f)

let _error (env: env) check_id s =
  let loc = Parse_info.first_loc_of_file (env.file) in
  let s = spf "%s (in ruleid: %s)" s env.id in
  let err = E.mk_error_loc loc (E.SemgrepMatchFound (check_id, s)) in
  pr2 (E.string_of_error err)

(*****************************************************************************)
(* Subparts checker *)
(*****************************************************************************)

let check_formula _env lang f =
  (* check duplicated patterns, essentially:
   *  $K: $PAT
   *  ...
   *  $K2: $PAT
   * but at the same level!
  *)

  f |> visit_old_formula (fun (pat, _pat_str) ->
    match pat, lang with
    | Left semgrep_pat, L (lang, _rest)  ->
        Check_pattern.check lang semgrep_pat
    | Right _spacegrep_pat, LGeneric -> ()
    | _ -> raise Impossible
  );
  ()

(*****************************************************************************)
(* Entry point *)
(*****************************************************************************)

let check r =
  check_formula r r.languages r.formula;
  ()
(*e: semgrep/metachecking/Check_rule.ml *)
