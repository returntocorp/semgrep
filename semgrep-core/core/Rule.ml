(*s: semgrep/core/Rule.ml *)
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
module MV = Metavariable

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* Data structure representing a semgrep rule.
 *
 * See also Mini_rule.ml where formula and many other features disappears.
 *
 * TODO:
 *  - parse more spacegrep and equivalences
*)

(*****************************************************************************)
(* Extended languages and patterns *)
(*****************************************************************************)

(* less: merge with xpattern_kind? *)
type xlang =
  (* for "real" semgrep *)
  | L of Lang.t * Lang.t list
  (* for pattern-regex *)
  | LNone
  (* for spacegrep *)
  | LGeneric
[@@deriving show]

type xpattern = {
  pat: xpattern_kind;
  (* two patterns may have different indentation, we don't care. We can
   * rely on the equality on p, which will do the right thing (e.g., abstract
   * away line position).
   * TODO: still right now we have some false positives because
   * for example in Python assert(...) and assert ... are considered equal
   * AST-wise, but it might be a bug! so I commented the @equal below.
  *)
  pstr: string (*  [@equal (fun _ _ -> true)] *);
}
and xpattern_kind =
  | Sem of Pattern.t
  | Spacegrep of spacegrep
  | Regexp of regexp

(* TODO: parse it via spacegrep/lib! *)
and spacegrep = string

and regexp = string

[@@deriving show, eq]

let mk_xpat pat pstr = { pat; pstr }

(*****************************************************************************)
(* Formula (patterns boolean composition) *)
(*****************************************************************************)

(* Classic boolean-logic/set operators with text range set semantic.
 * The main complication is the handling of metavariables and especially
 * negation in the presence of metavariables.
 * TODO: add tok (Parse_info.t) for good metachecking error locations.
*)
type formula =
  | P of xpattern (* a leaf pattern *)
  | X of extra

  | Not of formula
  | And of formula list
  | Or of formula list

(* extra conditions, usually on metavariable content *)
and extra =
  | MetavarRegexp of MV.mvar * regexp
  | MetavarComparison of metavariable_comparison
  | PatWherePython of string (* arbitrary code, dangerous! *)

(* See also matching/eval_generic.ml *)
and metavariable_comparison = {
  metavariable: MV.mvar;
  comparison: string;
  strip: bool option;
  base: int option;
}
[@@deriving show, eq]

(*****************************************************************************)
(* Old Formula style *)
(*****************************************************************************)

(* Unorthodox original pattern compositions.
 * See also the JSON schema in rule_schema.yaml
*)
type formula_old =
  (* pattern: *)
  | Pat of xpattern
  (* pattern-not: *)
  | PatNot of xpattern

  | PatExtra of extra

  (* pattern-inside: *)
  | PatInside of xpattern
  (* pattern-not-inside: *)
  | PatNotInside of xpattern

  (* pattern-either: *)
  | PatEither of formula_old list
  (* patterns: And? or Or? depends on formula inside, hmmm *)
  | Patterns of formula_old list

[@@deriving show, eq]


(* pattern formula *)
type pformula =
  | New of formula
  | Old of formula_old
[@@deriving show, eq]

(*****************************************************************************)
(* The rule *)
(*****************************************************************************)

type rule = {
  (* mandatory fields *)

  id: string;
  formula: pformula;
  message: string;
  severity: Mini_rule.severity;
  languages: xlang;

  file: string; (* for metachecking error location *)

  (* optional fields *)

  equivalences: string list option; (* TODO: parse them *)

  fix: string option;
  fix_regexp: (regexp * int option * string) option;

  paths: paths option;

  (* ex: [("owasp", "A1: Injection")] but can be anything *)
  metadata: JSON.t option;
}

and paths = {
  include_: regexp list;
  exclude: regexp list;
}
[@@deriving show]

(* alias *)
type t = rule
[@@deriving show]

type rules = rule list
[@@deriving show]


(*e: semgrep/core/Rule.ml *)
