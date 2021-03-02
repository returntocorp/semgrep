(* Yoann Padioleau
 *
 * Copyright (C) 2021 r2c
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
open AST_generic
module V = Visitor_AST

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* Analyzing a semgrep pattern for optimization purpose.
 *
 * It is useless to run the semgrep engine with rules containing specific
 * identifiers (e.g., 'eval') or strings (e.g., 'react.js')
 * that are never mentioned in the target file.
 *
 * We did something similar in Coccinelle I think. This also has been
 * mentioned many times (by Clint, HN, etc.).
 *
 * Right now the main optimization is to extract a regexp from
 * a pattern that we can run first on the target file.
 *
 * This module is currently used by:
 *  - Mini_rules_filter and Semgrep_generic, to skip certain mini-rules
 *    (but not entire files)
 *  - TODO: the bloom filter pattern extractor of Nathan and Emma
 *  - TODO: the Semgrep.ml engine to skip entire files!
 *
 * TODO:
 *  - extract identifiers, and basic strings
 *  - TODO extract filenames in import
 *  - TODO extract metavariables for Analyze_rule.ml
*)

(*****************************************************************************)
(* Identifier extractions *)
(*****************************************************************************)

let extract_specific_strings lang any =
  let res = ref [] in
  let visitor = V.mk_visitor {
    V.default_visitor with
    V.kident = (fun (_k, _) (str, _tok) ->
      if not (Pattern.is_special_identifier lang str)
      then Common.push str res
    );
    V.kexpr = (fun (k, _) x ->
      (match x with
       (* less: we could extract strings for the other literals too?
        * atoms, chars, even int?
        * We do now semantic equivance on integers between values so
        * 1000 is now equivalent to 1_000 so we can't "regexpize" it.
       *)
       | L (String (str, _tok)) ->
           if not (Pattern.is_special_string_literal str)
           then Common.push str res
       (* do not recurse there, the type does not have to be in the source *)
       | TypedMetavar _ ->
           ()
       | _ -> k x
      );
    );
  } in
  visitor any;
  Common2.uniq !res
