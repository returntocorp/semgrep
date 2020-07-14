(* Yoann Padioleau
 *
 * Copyright (C) 2020 r2c
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License (GPL)
 * version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * file license.txt for more details.
 *)
module PI = Parse_info

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* A few helpers to help factorize code between the different
 * Parse_xxx_tree_sitter.ml
 *)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)
type env = {
    file: Common.filename;
    (* get the charpos (offset) in file given a line x col *)
    conv: (int * int, int) Hashtbl.t;
}

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)

(* mostly a copy of Parse_info.full_charpos_to_pos_large *)
let line_col_to_pos = fun file ->

    let chan = open_in file in
    let size = Common2.filesize file + 2 in

    let charpos   = ref 0 in
    let line  = ref 0 in
    let h = Hashtbl.create size in

    let full_charpos_to_pos_aux () =
      try
        while true do begin
          let s = (input_line chan) in
          incr line;

          (* '... +1 do'  cos input_line dont return the trailing \n *)
          for i = 0 to (String.length s - 1) + 1 do
            Hashtbl.add h (!line, i) (!charpos + i);
          done;
          charpos := !charpos + String.length s + 1;
        end done
     with End_of_file ->
       Hashtbl.add h (!line, 0) !charpos;
    in
    full_charpos_to_pos_aux ();
    close_in chan;
    h

let token env (tok : Tree_sitter_run.Token.t) =
  let (loc, str) = tok in
  let h = env.conv in
  let start = loc.Tree_sitter_run.Loc.start in
  (* Parse_info is 1-line based and 0-column based, like Emacs *)
  let line = start.Tree_sitter_run.Loc.row + 1 in
  let column = start.Tree_sitter_run.Loc.column in
  let charpos =
    try Hashtbl.find h (line, column)
    with Not_found -> -1
  in
  let file = env.file in
  let tok_loc = { PI. str; charpos; line; column; file; } in
  { PI.token = PI.OriginTok tok_loc; transfo = PI.NoTransfo }

let str env (tok : Tree_sitter_run.Token.t) =
  let (_, s) = tok in
  s, token env tok
