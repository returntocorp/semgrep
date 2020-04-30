(* Yoann Padioleau
 *
 * Copyright (C) 2020 r2c
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
module Ast = Ast_generic
module V = Visitor_ast
module R = Tainting_rule
module Flag = Flag_semgrep

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* Simple wrapper around the tainting dataflow-based analysis in pfff.
 *
 * Here we pass matcher functions that uses semgrep patterns to
 * describe the source/sink/sanitizers.
 *)

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)

module F2 = Il
module DataflowY = Dataflow.Make (struct
  type node = F2.node
  type edge = F2.edge
  type flow = (node, edge) Ograph_extended.ograph_mutable
  let short_string_of_node n = Meta_il.short_string_of_node_kind n.F2.n
end)

let match_pat_instr pat =
  match pat with
  | [] -> (fun _ -> false)
  | xs ->
    let xs = xs |> List.map (function
        | Ast.E e -> e
        | _ -> failwith "Only Expr patterns are supported in tainting rules"
     )
    in
    let pat = Common2.foldl1 (fun x acc -> Ast.DisjExpr (x, acc)) xs in
    (fun instr ->
       let eorig = instr.Il.iorig in
       let matches_with_env = Semgrep_generic.match_e_e pat eorig in
       matches_with_env <> []
    )

 

let config_of_rule found_tainted_sink rule = 
  { Dataflow_tainting.
    is_source = match_pat_instr rule.R.source;
    is_sanitizer = match_pat_instr rule.R.sanitizer;
    is_sink = match_pat_instr rule.R.sink;
    
    found_tainted_sink;
  }

(*****************************************************************************)
(* Main entry point *)
(*****************************************************************************)

let check2 rules file ast =
  let matches = ref [] in

  let v = V.mk_visitor { V.default_visitor with
      V.kfunction_definition = (fun (_k, _) def ->
          let xs = Ast_to_il.stmt def.Ast.fbody in 
          let flow = Ilflow_build.cfg_of_stmts xs in

          rules |> List.iter (fun rule ->
            let found_tainted_sink = (fun instr _env ->
              Common.push { Match_result.
              rule = Tainting_rule.rule_of_tainting_rule rule;
              file;
              code = Ast.E (instr.Il.iorig);
              (* todo: use env from sink matching func?  *)
              env = [];
              } matches;
            ) in
            let config = config_of_rule found_tainted_sink rule in
            let mapping = Dataflow_tainting.fixpoint config flow in
            if !Flag.verbose
            then DataflowY.display_mapping flow mapping (fun () -> "()");
          )
      );
   } in
  v (Ast.Pr ast);

   !matches

let check a b c =
  Common.profile_code "Tainting_generic.check" (fun () -> check2 a b c)

