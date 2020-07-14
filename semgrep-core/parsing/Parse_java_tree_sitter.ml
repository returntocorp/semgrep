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
open Common
module AST = Ast_java
module CST = Tree_sitter_java.CST
module PI = Parse_info
(* open Ast_java *)
module G = AST_generic

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* Java parser using ocaml-tree-sitter-lang/java and converting
 * to pfff/lang_java/parsing/ast_java.ml
 *
 * The resulting AST can then be converted to the generic AST by using
 * pfff/lang_java/analyze/java_to_generic.ml
 *)

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)

(*****************************************************************************)
(* Boilerplate converter *)
(*****************************************************************************)
(* This was started by copying ocaml-tree-sitter-lang/java/Boilerplate.ml *)

(**
   Boilerplate to be used as a template when mapping the java CST
   to another type of tree.
*)

(* Disable warnings against unused variables *)
[@@@warning "-26-27"]

(* Disable warning against unused 'rec' *)
[@@@warning "-39"]

[@@@warning "-32"]

type env = unit

let token (env : env) (_tok : Tree_sitter_run.Token.t) =
  failwith "not implemented"

let blank (env : env) () =
  failwith "not implemented"

let todo (env : env) _ =
   failwith "not implemented"

let floating_point_type (env : env) (x : CST.floating_point_type) =
  (match x with
  | `Floa_point_type_float tok -> token env tok (* "float" *)
  | `Floa_point_type_doub tok -> token env tok (* "double" *)
  )

let octal_integer_literal (env : env) (tok : CST.octal_integer_literal) =
  token env tok (* octal_integer_literal *)

let binary_integer_literal (env : env) (tok : CST.binary_integer_literal) =
  token env tok (* binary_integer_literal *)

let identifier (env : env) (tok : CST.identifier) =
  token env tok (* pattern [a-zA-Z_]\w* *)

let hex_integer_literal (env : env) (tok : CST.hex_integer_literal) =
  token env tok (* hex_integer_literal *)

let integral_type (env : env) (x : CST.integral_type) =
  (match x with
  | `Inte_type_byte tok -> token env tok (* "byte" *)
  | `Inte_type_short tok -> token env tok (* "short" *)
  | `Inte_type_int tok -> token env tok (* "int" *)
  | `Inte_type_long tok -> token env tok (* "long" *)
  | `Inte_type_char tok -> token env tok (* "char" *)
  )

let decimal_floating_point_literal (env : env) (tok : CST.decimal_floating_point_literal) =
  token env tok (* decimal_floating_point_literal *)

let character_literal (env : env) (tok : CST.character_literal) =
  token env tok (* character_literal *)

let string_literal (env : env) (tok : CST.string_literal) =
  token env tok (* string_literal *)

let hex_floating_point_literal (env : env) (tok : CST.hex_floating_point_literal) =
  token env tok (* hex_floating_point_literal *)

let decimal_integer_literal (env : env) (tok : CST.decimal_integer_literal) =
  token env tok (* decimal_integer_literal *)

let requires_modifier (env : env) (x : CST.requires_modifier) =
  (match x with
  | `Requis_modi_tran tok -> token env tok (* "transitive" *)
  | `Requis_modi_stat tok -> token env tok (* "static" *)
  )

let rec scoped_identifier (env : env) ((v1, v2, v3) : CST.scoped_identifier) =
  let v1 =
    (match v1 with
    | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
    | `Choice_open x ->
        (match x with
        | `Open tok -> token env tok (* "open" *)
        | `Modu tok -> token env tok (* "module" *)
        )
    | `Scop_id x -> scoped_identifier env x
    )
  in
  let v2 = token env v2 (* "." *) in
  let v3 = token env v3 (* pattern [a-zA-Z_]\w* *) in
  todo env (v1, v2, v3)

let inferred_parameters (env : env) ((v1, v2, v3, v4) : CST.inferred_parameters) =
  let v1 = token env v1 (* "(" *) in
  let v2 = token env v2 (* pattern [a-zA-Z_]\w* *) in
  let v3 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = token env v2 (* pattern [a-zA-Z_]\w* *) in
      todo env (v1, v2)
    ) v3
  in
  let v4 = token env v4 (* ")" *) in
  todo env (v1, v2, v3, v4)

let literal (env : env) (x : CST.literal) =
  (match x with
  | `Lit_deci_int_lit tok ->
      token env tok (* decimal_integer_literal *)
  | `Lit_hex_int_lit tok ->
      token env tok (* hex_integer_literal *)
  | `Lit_octal_int_lit tok ->
      token env tok (* octal_integer_literal *)
  | `Lit_bin_int_lit tok ->
      token env tok (* binary_integer_literal *)
  | `Lit_deci_floa_point_lit tok ->
      token env tok (* decimal_floating_point_literal *)
  | `Lit_hex_floa_point_lit tok ->
      token env tok (* hex_floating_point_literal *)
  | `Lit_true tok -> token env tok (* "true" *)
  | `Lit_false tok -> token env tok (* "false" *)
  | `Lit_char_lit tok -> token env tok (* character_literal *)
  | `Lit_str_lit tok -> token env tok (* string_literal *)
  | `Lit_null_lit tok -> token env tok (* "null" *)
  )

let module_directive (env : env) ((v1, v2) : CST.module_directive) =
  let v1 =
    (match v1 with
    | `Requis_rep_requis_modi_choice_id (v1, v2, v3) ->
        let v1 = token env v1 (* "requires" *) in
        let v2 = List.map (requires_modifier env) v2 in
        let v3 =
          (match v3 with
          | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
          | `Choice_open x ->
              (match x with
              | `Open tok -> token env tok (* "open" *)
              | `Modu tok -> token env tok (* "module" *)
              )
          | `Scop_id x -> scoped_identifier env x
          )
        in
        todo env (v1, v2, v3)
    | `Expors_choice_id_opt_to_opt_choice_id_rep_COMMA_choice_id (v1, v2, v3, v4, v5) ->
        let v1 = token env v1 (* "exports" *) in
        let v2 =
          (match v2 with
          | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
          | `Choice_open x ->
              (match x with
              | `Open tok -> token env tok (* "open" *)
              | `Modu tok -> token env tok (* "module" *)
              )
          | `Scop_id x -> scoped_identifier env x
          )
        in
        let v3 =
          (match v3 with
          | Some tok -> token env tok (* "to" *)
          | None -> todo env ())
        in
        let v4 =
          (match v4 with
          | Some x ->
              (match x with
              | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
              | `Choice_open x ->
                  (match x with
                  | `Open tok -> token env tok (* "open" *)
                  | `Modu tok -> token env tok (* "module" *)
                  )
              | `Scop_id x -> scoped_identifier env x
              )
          | None -> todo env ())
        in
        let v5 =
          List.map (fun (v1, v2) ->
            let v1 = token env v1 (* "," *) in
            let v2 =
              (match v2 with
              | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
              | `Choice_open x ->
                  (match x with
                  | `Open tok -> token env tok (* "open" *)
                  | `Modu tok -> token env tok (* "module" *)
                  )
              | `Scop_id x -> scoped_identifier env x
              )
            in
            todo env (v1, v2)
          ) v5
        in
        todo env (v1, v2, v3, v4, v5)
    | `Opens_choice_id_opt_to_opt_choice_id_rep_COMMA_choice_id (v1, v2, v3, v4, v5) ->
        let v1 = token env v1 (* "opens" *) in
        let v2 =
          (match v2 with
          | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
          | `Choice_open x ->
              (match x with
              | `Open tok -> token env tok (* "open" *)
              | `Modu tok -> token env tok (* "module" *)
              )
          | `Scop_id x -> scoped_identifier env x
          )
        in
        let v3 =
          (match v3 with
          | Some tok -> token env tok (* "to" *)
          | None -> todo env ())
        in
        let v4 =
          (match v4 with
          | Some x ->
              (match x with
              | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
              | `Choice_open x ->
                  (match x with
                  | `Open tok -> token env tok (* "open" *)
                  | `Modu tok -> token env tok (* "module" *)
                  )
              | `Scop_id x -> scoped_identifier env x
              )
          | None -> todo env ())
        in
        let v5 =
          List.map (fun (v1, v2) ->
            let v1 = token env v1 (* "," *) in
            let v2 =
              (match v2 with
              | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
              | `Choice_open x ->
                  (match x with
                  | `Open tok -> token env tok (* "open" *)
                  | `Modu tok -> token env tok (* "module" *)
                  )
              | `Scop_id x -> scoped_identifier env x
              )
            in
            todo env (v1, v2)
          ) v5
        in
        todo env (v1, v2, v3, v4, v5)
    | `Uses_choice_id (v1, v2) ->
        let v1 = token env v1 (* "uses" *) in
        let v2 =
          (match v2 with
          | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
          | `Choice_open x ->
              (match x with
              | `Open tok -> token env tok (* "open" *)
              | `Modu tok -> token env tok (* "module" *)
              )
          | `Scop_id x -> scoped_identifier env x
          )
        in
        todo env (v1, v2)
    | `Provis_choice_id_with_choice_id_rep_COMMA_choice_id (v1, v2, v3, v4, v5) ->
        let v1 = token env v1 (* "provides" *) in
        let v2 =
          (match v2 with
          | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
          | `Choice_open x ->
              (match x with
              | `Open tok -> token env tok (* "open" *)
              | `Modu tok -> token env tok (* "module" *)
              )
          | `Scop_id x -> scoped_identifier env x
          )
        in
        let v3 = token env v3 (* "with" *) in
        let v4 =
          (match v4 with
          | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
          | `Choice_open x ->
              (match x with
              | `Open tok -> token env tok (* "open" *)
              | `Modu tok -> token env tok (* "module" *)
              )
          | `Scop_id x -> scoped_identifier env x
          )
        in
        let v5 =
          List.map (fun (v1, v2) ->
            let v1 = token env v1 (* "," *) in
            let v2 =
              (match v2 with
              | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
              | `Choice_open x ->
                  (match x with
                  | `Open tok -> token env tok (* "open" *)
                  | `Modu tok -> token env tok (* "module" *)
                  )
              | `Scop_id x -> scoped_identifier env x
              )
            in
            todo env (v1, v2)
          ) v5
        in
        todo env (v1, v2, v3, v4, v5)
    )
  in
  let v2 = token env v2 (* ";" *) in
  todo env (v1, v2)

let module_body (env : env) ((v1, v2, v3) : CST.module_body) =
  let v1 = token env v1 (* "{" *) in
  let v2 = List.map (module_directive env) v2 in
  let v3 = token env v3 (* "}" *) in
  todo env (v1, v2, v3)

let rec expression (env : env) (x : CST.expression) =
  (match x with
  | `Exp_assign_exp (v1, v2, v3) ->
      let v1 =
        (match v1 with
        | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        | `Choice_open x ->
            (match x with
            | `Open tok -> token env tok (* "open" *)
            | `Modu tok -> token env tok (* "module" *)
            )
        | `Field_acce x -> field_access env x
        | `Array_acce x -> array_access env x
        )
      in
      let v2 =
        (match v2 with
        | `EQ tok -> token env tok (* "=" *)
        | `PLUSEQ tok -> token env tok (* "+=" *)
        | `DASHEQ tok -> token env tok (* "-=" *)
        | `STAREQ tok -> token env tok (* "*=" *)
        | `SLASHEQ tok -> token env tok (* "/=" *)
        | `AMPEQ tok -> token env tok (* "&=" *)
        | `BAREQ tok -> token env tok (* "|=" *)
        | `HATEQ tok -> token env tok (* "^=" *)
        | `PERCEQ tok -> token env tok (* "%=" *)
        | `LTLTEQ tok -> token env tok (* "<<=" *)
        | `GTGTEQ tok -> token env tok (* ">>=" *)
        | `GTGTGTEQ tok -> token env tok (* ">>>=" *)
        )
      in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Exp_bin_exp x -> binary_expression env x
  | `Exp_inst_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "instanceof" *) in
      let v3 = type_ env v3 in
      todo env (v1, v2, v3)
  | `Exp_lamb_exp (v1, v2, v3) ->
      let v1 =
        (match v1 with
        | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        | `Form_params x -> formal_parameters env x
        | `Infe_params x -> inferred_parameters env x
        )
      in
      let v2 = token env v2 (* "->" *) in
      let v3 =
        (match v3 with
        | `Exp x -> expression env x
        | `Blk x -> block env x
        )
      in
      todo env (v1, v2, v3)
  | `Exp_tern_exp (v1, v2, v3, v4, v5) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "?" *) in
      let v3 = expression env v3 in
      let v4 = token env v4 (* ":" *) in
      let v5 = expression env v5 in
      todo env (v1, v2, v3, v4, v5)
  | `Exp_upda_exp x -> update_expression env x
  | `Exp_prim x -> primary env x
  | `Exp_un_exp x -> unary_expression env x
  | `Exp_cast_exp (v1, v2, v3, v4, v5) ->
      let v1 = token env v1 (* "(" *) in
      let v2 = type_ env v2 in
      let v3 =
        List.map (fun (v1, v2) ->
          let v1 = token env v1 (* "&" *) in
          let v2 = type_ env v2 in
          todo env (v1, v2)
        ) v3
      in
      let v4 = token env v4 (* ")" *) in
      let v5 = expression env v5 in
      todo env (v1, v2, v3, v4, v5)
  )


and binary_expression (env : env) (x : CST.binary_expression) =
  (match x with
  | `Bin_exp_exp_GT_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* ">" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_LT_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "<" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_EQEQ_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "==" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_GTEQ_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* ">=" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_LTEQ_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "<=" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_BANGEQ_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "!=" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_AMPAMP_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "&&" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_BARBAR_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "||" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_PLUS_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "+" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_DASH_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "-" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_STAR_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "*" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_SLASH_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "/" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_AMP_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "&" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_BAR_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "|" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_HAT_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "^" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_PERC_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "%" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_LTLT_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "<<" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_GTGT_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* ">>" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  | `Bin_exp_exp_GTGTGT_exp (v1, v2, v3) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* ">>>" *) in
      let v3 = expression env v3 in
      todo env (v1, v2, v3)
  )


and unary_expression (env : env) (x : CST.unary_expression) =
  (match x with
  | `Un_exp_PLUS_exp (v1, v2) ->
      let v1 = token env v1 (* "+" *) in
      let v2 = expression env v2 in
      todo env (v1, v2)
  | `Un_exp_DASH_exp (v1, v2) ->
      let v1 = token env v1 (* "-" *) in
      let v2 = expression env v2 in
      todo env (v1, v2)
  | `Un_exp_BANG_exp (v1, v2) ->
      let v1 = token env v1 (* "!" *) in
      let v2 = expression env v2 in
      todo env (v1, v2)
  | `Un_exp_TILDE_exp (v1, v2) ->
      let v1 = token env v1 (* "~" *) in
      let v2 = expression env v2 in
      todo env (v1, v2)
  )


and update_expression (env : env) (x : CST.update_expression) =
  (match x with
  | `Exp_PLUSPLUS (v1, v2) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "++" *) in
      todo env (v1, v2)
  | `Exp_DASHDASH (v1, v2) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* "--" *) in
      todo env (v1, v2)
  | `PLUSPLUS_exp (v1, v2) ->
      let v1 = token env v1 (* "++" *) in
      let v2 = expression env v2 in
      todo env (v1, v2)
  | `DASHDASH_exp (v1, v2) ->
      let v1 = token env v1 (* "--" *) in
      let v2 = expression env v2 in
      todo env (v1, v2)
  )


and primary (env : env) (x : CST.primary) =
  (match x with
  | `Prim_lit x -> literal env x
  | `Prim_class_lit (v1, v2, v3) ->
      let v1 = unannotated_type env v1 in
      let v2 = token env v2 (* "." *) in
      let v3 = token env v3 (* "class" *) in
      todo env (v1, v2, v3)
  | `Prim_this tok -> token env tok (* "this" *)
  | `Prim_id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
  | `Prim_choice_open x ->
      (match x with
      | `Open tok -> token env tok (* "open" *)
      | `Modu tok -> token env tok (* "module" *)
      )
  | `Prim_paren_exp x -> parenthesized_expression env x
  | `Prim_obj_crea_exp x ->
      object_creation_expression env x
  | `Prim_field_acce x -> field_access env x
  | `Prim_array_acce x -> array_access env x
  | `Prim_meth_invo (v1, v2) ->
      let v1 =
        (match v1 with
        | `Choice_id x ->
            (match x with
            | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
            | `Choice_open x ->
                (match x with
                | `Open tok -> token env tok (* "open" *)
                | `Modu tok -> token env tok (* "module" *)
                )
            )
        | `Choice_prim_DOT_opt_super_DOT_opt_type_args_choice_id (v1, v2, v3, v4, v5) ->
            let v1 =
              (match v1 with
              | `Prim x -> primary env x
              | `Super tok -> token env tok (* "super" *)
              )
            in
            let v2 = token env v2 (* "." *) in
            let v3 =
              (match v3 with
              | Some (v1, v2) ->
                  let v1 = token env v1 (* "super" *) in
                  let v2 = token env v2 (* "." *) in
                  todo env (v1, v2)
              | None -> todo env ())
            in
            let v4 =
              (match v4 with
              | Some x -> type_arguments env x
              | None -> todo env ())
            in
            let v5 =
              (match v5 with
              | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
              | `Choice_open x ->
                  (match x with
                  | `Open tok -> token env tok (* "open" *)
                  | `Modu tok -> token env tok (* "module" *)
                  )
              )
            in
            todo env (v1, v2, v3, v4, v5)
        )
      in
      let v2 = argument_list env v2 in
      todo env (v1, v2)
  | `Prim_meth_ref (v1, v2, v3, v4) ->
      let v1 =
        (match v1 with
        | `Type x -> type_ env x
        | `Prim x -> primary env x
        | `Super tok -> token env tok (* "super" *)
        )
      in
      let v2 = token env v2 (* "::" *) in
      let v3 =
        (match v3 with
        | Some x -> type_arguments env x
        | None -> todo env ())
      in
      let v4 =
        (match v4 with
        | `New tok -> token env tok (* "new" *)
        | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        )
      in
      todo env (v1, v2, v3, v4)
  | `Prim_array_crea_exp (v1, v2, v3) ->
      let v1 = token env v1 (* "new" *) in
      let v2 =
        (match v2 with
        | `Void_type tok -> token env tok (* "void" *)
        | `Inte_type x -> integral_type env x
        | `Floa_point_type x -> floating_point_type env x
        | `Bool_type tok -> token env tok (* "boolean" *)
        | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        | `Scop_type_id x -> scoped_type_identifier env x
        | `Gene_type x -> generic_type env x
        )
      in
      let v3 =
        (match v3 with
        | `Rep1_dimens_expr_opt_dimens (v1, v2) ->
            let v1 = List.map (dimensions_expr env) v1 in
            let v2 =
              (match v2 with
              | Some x -> dimensions env x
              | None -> todo env ())
            in
            todo env (v1, v2)
        | `Dimens_array_init (v1, v2) ->
            let v1 = dimensions env v1 in
            let v2 = array_initializer env v2 in
            todo env (v1, v2)
        )
      in
      todo env (v1, v2, v3)
  )


and dimensions_expr (env : env) ((v1, v2, v3, v4) : CST.dimensions_expr) =
  let v1 = List.map (annotation env) v1 in
  let v2 = token env v2 (* "[" *) in
  let v3 = expression env v3 in
  let v4 = token env v4 (* "]" *) in
  todo env (v1, v2, v3, v4)


and parenthesized_expression (env : env) ((v1, v2, v3) : CST.parenthesized_expression) =
  let v1 = token env v1 (* "(" *) in
  let v2 = expression env v2 in
  let v3 = token env v3 (* ")" *) in
  todo env (v1, v2, v3)


and object_creation_expression (env : env) (x : CST.object_creation_expression) =
  (match x with
  | `Obj_crea_exp_unqu_obj_crea_exp x ->
      unqualified_object_creation_expression env x
  | `Obj_crea_exp_prim_DOT_unqu_obj_crea_exp (v1, v2, v3) ->
      let v1 = primary env v1 in
      let v2 = token env v2 (* "." *) in
      let v3 =
        unqualified_object_creation_expression env v3
      in
      todo env (v1, v2, v3)
  )


and unqualified_object_creation_expression (env : env) ((v1, v2, v3, v4, v5) : CST.unqualified_object_creation_expression) =
  let v1 = token env v1 (* "new" *) in
  let v2 =
    (match v2 with
    | Some x -> type_arguments env x
    | None -> todo env ())
  in
  let v3 =
    (match v3 with
    | `Void_type tok -> token env tok (* "void" *)
    | `Inte_type x -> integral_type env x
    | `Floa_point_type x -> floating_point_type env x
    | `Bool_type tok -> token env tok (* "boolean" *)
    | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
    | `Scop_type_id x -> scoped_type_identifier env x
    | `Gene_type x -> generic_type env x
    )
  in
  let v4 = argument_list env v4 in
  let v5 =
    (match v5 with
    | Some x -> class_body env x
    | None -> todo env ())
  in
  todo env (v1, v2, v3, v4, v5)


and field_access (env : env) ((v1, v2, v3, v4) : CST.field_access) =
  let v1 =
    (match v1 with
    | `Prim x -> primary env x
    | `Super tok -> token env tok (* "super" *)
    )
  in
  let v2 =
    (match v2 with
    | Some (v1, v2) ->
        let v1 = token env v1 (* "." *) in
        let v2 = token env v2 (* "super" *) in
        todo env (v1, v2)
    | None -> todo env ())
  in
  let v3 = token env v3 (* "." *) in
  let v4 =
    (match v4 with
    | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
    | `Choice_open x ->
        (match x with
        | `Open tok -> token env tok (* "open" *)
        | `Modu tok -> token env tok (* "module" *)
        )
    | `This tok -> token env tok (* "this" *)
    )
  in
  todo env (v1, v2, v3, v4)


and array_access (env : env) ((v1, v2, v3, v4) : CST.array_access) =
  let v1 = primary env v1 in
  let v2 = token env v2 (* "[" *) in
  let v3 = expression env v3 in
  let v4 = token env v4 (* "]" *) in
  todo env (v1, v2, v3, v4)


and argument_list (env : env) ((v1, v2, v3) : CST.argument_list) =
  let v1 = token env v1 (* "(" *) in
  let v2 =
    (match v2 with
    | Some (v1, v2) ->
        let v1 = expression env v1 in
        let v2 =
          List.map (fun (v1, v2) ->
            let v1 = token env v1 (* "," *) in
            let v2 = expression env v2 in
            todo env (v1, v2)
          ) v2
        in
        todo env (v1, v2)
    | None -> todo env ())
  in
  let v3 = token env v3 (* ")" *) in
  todo env (v1, v2, v3)


and type_arguments (env : env) ((v1, v2, v3) : CST.type_arguments) =
  let v1 = token env v1 (* "<" *) in
  let v2 =
    (match v2 with
    | Some (v1, v2) ->
        let v1 =
          (match v1 with
          | `Type x -> type_ env x
          | `Wild x -> wildcard env x
          )
        in
        let v2 =
          List.map (fun (v1, v2) ->
            let v1 = token env v1 (* "," *) in
            let v2 =
              (match v2 with
              | `Type x -> type_ env x
              | `Wild x -> wildcard env x
              )
            in
            todo env (v1, v2)
          ) v2
        in
        todo env (v1, v2)
    | None -> todo env ())
  in
  let v3 = token env v3 (* ">" *) in
  todo env (v1, v2, v3)


and wildcard (env : env) ((v1, v2, v3) : CST.wildcard) =
  let v1 = List.map (annotation env) v1 in
  let v2 = token env v2 (* "?" *) in
  let v3 =
    (match v3 with
    | Some x -> wildcard_bounds env x
    | None -> todo env ())
  in
  todo env (v1, v2, v3)


and wildcard_bounds (env : env) (x : CST.wildcard_bounds) =
  (match x with
  | `Wild_bounds_extens_type (v1, v2) ->
      let v1 = token env v1 (* "extends" *) in
      let v2 = type_ env v2 in
      todo env (v1, v2)
  | `Wild_bounds_super_type (v1, v2) ->
      let v1 = token env v1 (* "super" *) in
      let v2 = type_ env v2 in
      todo env (v1, v2)
  )


and dimensions (env : env) (xs : CST.dimensions) =
  List.map (fun (v1, v2, v3) ->
    let v1 = List.map (annotation env) v1 in
    let v2 = token env v2 (* "[" *) in
    let v3 = token env v3 (* "]" *) in
    todo env (v1, v2, v3)
  ) xs


and statement (env : env) (x : CST.statement) =
  (match x with
  | `Stmt_decl x -> declaration env x
  | `Stmt_exp_stmt (v1, v2) ->
      let v1 = expression env v1 in
      let v2 = token env v2 (* ";" *) in
      todo env (v1, v2)
  | `Stmt_labe_stmt (v1, v2, v3) ->
      let v1 = token env v1 (* pattern [a-zA-Z_]\w* *) in
      let v2 = token env v2 (* ":" *) in
      let v3 = statement env v3 in
      todo env (v1, v2, v3)
  | `Stmt_if_stmt (v1, v2, v3, v4) ->
      let v1 = token env v1 (* "if" *) in
      let v2 = parenthesized_expression env v2 in
      let v3 = statement env v3 in
      let v4 =
        (match v4 with
        | Some (v1, v2) ->
            let v1 = token env v1 (* "else" *) in
            let v2 = statement env v2 in
            todo env (v1, v2)
        | None -> todo env ())
      in
      todo env (v1, v2, v3, v4)
  | `Stmt_while_stmt (v1, v2, v3) ->
      let v1 = token env v1 (* "while" *) in
      let v2 = parenthesized_expression env v2 in
      let v3 = statement env v3 in
      todo env (v1, v2, v3)
  | `Stmt_for_stmt (v1, v2, v3, v4, v5, v6, v7, v8) ->
      let v1 = token env v1 (* "for" *) in
      let v2 = token env v2 (* "(" *) in
      let v3 =
        (match v3 with
        | `Local_var_decl x -> local_variable_declaration env x
        | `Opt_exp_rep_COMMA_exp_SEMI (v1, v2) ->
            let v1 =
              (match v1 with
              | Some (v1, v2) ->
                  let v1 = expression env v1 in
                  let v2 =
                    List.map (fun (v1, v2) ->
                      let v1 = token env v1 (* "," *) in
                      let v2 = expression env v2 in
                      todo env (v1, v2)
                    ) v2
                  in
                  todo env (v1, v2)
              | None -> todo env ())
            in
            let v2 = token env v2 (* ";" *) in
            todo env (v1, v2)
        )
      in
      let v4 =
        (match v4 with
        | Some x -> expression env x
        | None -> todo env ())
      in
      let v5 = token env v5 (* ";" *) in
      let v6 =
        (match v6 with
        | Some (v1, v2) ->
            let v1 = expression env v1 in
            let v2 =
              List.map (fun (v1, v2) ->
                let v1 = token env v1 (* "," *) in
                let v2 = expression env v2 in
                todo env (v1, v2)
              ) v2
            in
            todo env (v1, v2)
        | None -> todo env ())
      in
      let v7 = token env v7 (* ")" *) in
      let v8 = statement env v8 in
      todo env (v1, v2, v3, v4, v5, v6, v7, v8)
  | `Stmt_enha_for_stmt (v1, v2, v3, v4, v5, v6, v7, v8, v9) ->
      let v1 = token env v1 (* "for" *) in
      let v2 = token env v2 (* "(" *) in
      let v3 =
        (match v3 with
        | Some x -> modifiers env x
        | None -> todo env ())
      in
      let v4 = unannotated_type env v4 in
      let v5 = variable_declarator_id env v5 in
      let v6 = token env v6 (* ":" *) in
      let v7 = expression env v7 in
      let v8 = token env v8 (* ")" *) in
      let v9 = statement env v9 in
      todo env (v1, v2, v3, v4, v5, v6, v7, v8, v9)
  | `Stmt_blk x -> block env x
  | `Stmt_SEMI tok -> token env tok (* ";" *)
  | `Stmt_asse_stmt x -> assert_statement env x
  | `Stmt_swit_stmt (v1, v2, v3) ->
      let v1 = token env v1 (* "switch" *) in
      let v2 = parenthesized_expression env v2 in
      let v3 = switch_block env v3 in
      todo env (v1, v2, v3)
  | `Stmt_do_stmt (v1, v2, v3, v4, v5) ->
      let v1 = token env v1 (* "do" *) in
      let v2 = statement env v2 in
      let v3 = token env v3 (* "while" *) in
      let v4 = parenthesized_expression env v4 in
      let v5 = token env v5 (* ";" *) in
      todo env (v1, v2, v3, v4, v5)
  | `Stmt_brk_stmt (v1, v2, v3) ->
      let v1 = token env v1 (* "break" *) in
      let v2 =
        (match v2 with
        | Some tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        | None -> todo env ())
      in
      let v3 = token env v3 (* ";" *) in
      todo env (v1, v2, v3)
  | `Stmt_cont_stmt (v1, v2, v3) ->
      let v1 = token env v1 (* "continue" *) in
      let v2 =
        (match v2 with
        | Some tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        | None -> todo env ())
      in
      let v3 = token env v3 (* ";" *) in
      todo env (v1, v2, v3)
  | `Stmt_ret_stmt (v1, v2, v3) ->
      let v1 = token env v1 (* "return" *) in
      let v2 =
        (match v2 with
        | Some x -> expression env x
        | None -> todo env ())
      in
      let v3 = token env v3 (* ";" *) in
      todo env (v1, v2, v3)
  | `Stmt_sync_stmt (v1, v2, v3) ->
      let v1 = token env v1 (* "synchronized" *) in
      let v2 = parenthesized_expression env v2 in
      let v3 = block env v3 in
      todo env (v1, v2, v3)
  | `Stmt_local_var_decl x ->
      local_variable_declaration env x
  | `Stmt_throw_stmt (v1, v2, v3) ->
      let v1 = token env v1 (* "throw" *) in
      let v2 = expression env v2 in
      let v3 = token env v3 (* ";" *) in
      todo env (v1, v2, v3)
  | `Stmt_try_stmt (v1, v2, v3) ->
      let v1 = token env v1 (* "try" *) in
      let v2 = block env v2 in
      let v3 =
        (match v3 with
        | `Rep1_catch_clau xs -> List.map (catch_clause env) xs
        | `Rep_catch_clau_fina_clau (v1, v2) ->
            let v1 = List.map (catch_clause env) v1 in
            let v2 = finally_clause env v2 in
            todo env (v1, v2)
        )
      in
      todo env (v1, v2, v3)
  | `Stmt_try_with_resous_stmt (v1, v2, v3, v4, v5) ->
      let v1 = token env v1 (* "try" *) in
      let v2 = resource_specification env v2 in
      let v3 = block env v3 in
      let v4 = List.map (catch_clause env) v4 in
      let v5 =
        (match v5 with
        | Some x -> finally_clause env x
        | None -> todo env ())
      in
      todo env (v1, v2, v3, v4, v5)
  )


and block (env : env) ((v1, v2, v3) : CST.block) =
  let v1 = token env v1 (* "{" *) in
  let v2 = List.map (statement env) v2 in
  let v3 = token env v3 (* "}" *) in
  todo env (v1, v2, v3)


and assert_statement (env : env) (x : CST.assert_statement) =
  (match x with
  | `Asse_stmt_asse_exp_SEMI (v1, v2, v3) ->
      let v1 = token env v1 (* "assert" *) in
      let v2 = expression env v2 in
      let v3 = token env v3 (* ";" *) in
      todo env (v1, v2, v3)
  | `Asse_stmt_asse_exp_COLON_exp_SEMI (v1, v2, v3, v4, v5) ->
      let v1 = token env v1 (* "assert" *) in
      let v2 = expression env v2 in
      let v3 = token env v3 (* ":" *) in
      let v4 = expression env v4 in
      let v5 = token env v5 (* ";" *) in
      todo env (v1, v2, v3, v4, v5)
  )


and switch_block (env : env) ((v1, v2, v3) : CST.switch_block) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    List.map (fun x ->
      (match x with
      | `Swit_label x -> switch_label env x
      | `Stmt x -> statement env x
      )
    ) v2
  in
  let v3 = token env v3 (* "}" *) in
  todo env (v1, v2, v3)


and switch_label (env : env) (x : CST.switch_label) =
  (match x with
  | `Swit_label_case_exp_COLON (v1, v2, v3) ->
      let v1 = token env v1 (* "case" *) in
      let v2 = expression env v2 in
      let v3 = token env v3 (* ":" *) in
      todo env (v1, v2, v3)
  | `Swit_label_defa_COLON (v1, v2) ->
      let v1 = token env v1 (* "default" *) in
      let v2 = token env v2 (* ":" *) in
      todo env (v1, v2)
  )


and catch_clause (env : env) ((v1, v2, v3, v4, v5) : CST.catch_clause) =
  let v1 = token env v1 (* "catch" *) in
  let v2 = token env v2 (* "(" *) in
  let v3 = catch_formal_parameter env v3 in
  let v4 = token env v4 (* ")" *) in
  let v5 = block env v5 in
  todo env (v1, v2, v3, v4, v5)


and catch_formal_parameter (env : env) ((v1, v2, v3) : CST.catch_formal_parameter) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = catch_type env v2 in
  let v3 = variable_declarator_id env v3 in
  todo env (v1, v2, v3)


and catch_type (env : env) ((v1, v2) : CST.catch_type) =
  let v1 = unannotated_type env v1 in
  let v2 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "|" *) in
      let v2 = unannotated_type env v2 in
      todo env (v1, v2)
    ) v2
  in
  todo env (v1, v2)


and finally_clause (env : env) ((v1, v2) : CST.finally_clause) =
  let v1 = token env v1 (* "finally" *) in
  let v2 = block env v2 in
  todo env (v1, v2)


and resource_specification (env : env) ((v1, v2, v3, v4, v5) : CST.resource_specification) =
  let v1 = token env v1 (* "(" *) in
  let v2 = resource env v2 in
  let v3 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* ";" *) in
      let v2 = resource env v2 in
      todo env (v1, v2)
    ) v3
  in
  let v4 =
    (match v4 with
    | Some tok -> token env tok (* ";" *)
    | None -> todo env ())
  in
  let v5 = token env v5 (* ")" *) in
  todo env (v1, v2, v3, v4, v5)


and resource (env : env) (x : CST.resource) =
  (match x with
  | `Reso_opt_modifs_unan_type_var_decl_id_EQ_exp (v1, v2, v3, v4, v5) ->
      let v1 =
        (match v1 with
        | Some x -> modifiers env x
        | None -> todo env ())
      in
      let v2 = unannotated_type env v2 in
      let v3 = variable_declarator_id env v3 in
      let v4 = token env v4 (* "=" *) in
      let v5 = expression env v5 in
      todo env (v1, v2, v3, v4, v5)
  | `Reso_id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
  | `Reso_field_acce x -> field_access env x
  )


and annotation (env : env) (x : CST.annotation) =
  (match x with
  | `Anno_mark_anno (v1, v2) ->
      let v1 = token env v1 (* "@" *) in
      let v2 =
        (match v2 with
        | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        | `Choice_open x ->
            (match x with
            | `Open tok -> token env tok (* "open" *)
            | `Modu tok -> token env tok (* "module" *)
            )
        | `Scop_id x -> scoped_identifier env x
        )
      in
      todo env (v1, v2)
  | `Anno_anno_ (v1, v2, v3) ->
      let v1 = token env v1 (* "@" *) in
      let v2 =
        (match v2 with
        | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        | `Choice_open x ->
            (match x with
            | `Open tok -> token env tok (* "open" *)
            | `Modu tok -> token env tok (* "module" *)
            )
        | `Scop_id x -> scoped_identifier env x
        )
      in
      let v3 = annotation_argument_list env v3 in
      todo env (v1, v2, v3)
  )


and annotation_argument_list (env : env) ((v1, v2, v3) : CST.annotation_argument_list) =
  let v1 = token env v1 (* "(" *) in
  let v2 =
    (match v2 with
    | `Elem_value x -> element_value env x
    | `Opt_elem_value_pair_rep_COMMA_elem_value_pair opt ->
        (match opt with
        | Some (v1, v2) ->
            let v1 = element_value_pair env v1 in
            let v2 =
              List.map (fun (v1, v2) ->
                let v1 = token env v1 (* "," *) in
                let v2 = element_value_pair env v2 in
                todo env (v1, v2)
              ) v2
            in
            todo env (v1, v2)
        | None -> todo env ())
    )
  in
  let v3 = token env v3 (* ")" *) in
  todo env (v1, v2, v3)


and element_value_pair (env : env) ((v1, v2, v3) : CST.element_value_pair) =
  let v1 = token env v1 (* pattern [a-zA-Z_]\w* *) in
  let v2 = token env v2 (* "=" *) in
  let v3 = element_value env v3 in
  todo env (v1, v2, v3)


and element_value (env : env) (x : CST.element_value) =
  (match x with
  | `Exp x -> expression env x
  | `Elem_value_array_init (v1, v2, v3, v4) ->
      let v1 = token env v1 (* "{" *) in
      let v2 =
        (match v2 with
        | Some (v1, v2) ->
            let v1 = element_value env v1 in
            let v2 =
              List.map (fun (v1, v2) ->
                let v1 = token env v1 (* "," *) in
                let v2 = element_value env v2 in
                todo env (v1, v2)
              ) v2
            in
            todo env (v1, v2)
        | None -> todo env ())
      in
      let v3 =
        (match v3 with
        | Some tok -> token env tok (* "," *)
        | None -> todo env ())
      in
      let v4 = token env v4 (* "}" *) in
      todo env (v1, v2, v3, v4)
  | `Anno x -> annotation env x
  )


and declaration (env : env) (x : CST.declaration) =
  (match x with
  | `Modu_decl (v1, v2, v3, v4, v5) ->
      let v1 = List.map (annotation env) v1 in
      let v2 =
        (match v2 with
        | Some tok -> token env tok (* "open" *)
        | None -> todo env ())
      in
      let v3 = token env v3 (* "module" *) in
      let v4 =
        (match v4 with
        | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        | `Choice_open x ->
            (match x with
            | `Open tok -> token env tok (* "open" *)
            | `Modu tok -> token env tok (* "module" *)
            )
        | `Scop_id x -> scoped_identifier env x
        )
      in
      let v5 = module_body env v5 in
      todo env (v1, v2, v3, v4, v5)
  | `Pack_decl (v1, v2, v3, v4) ->
      let v1 = List.map (annotation env) v1 in
      let v2 = token env v2 (* "package" *) in
      let v3 =
        (match v3 with
        | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        | `Choice_open x ->
            (match x with
            | `Open tok -> token env tok (* "open" *)
            | `Modu tok -> token env tok (* "module" *)
            )
        | `Scop_id x -> scoped_identifier env x
        )
      in
      let v4 = token env v4 (* ";" *) in
      todo env (v1, v2, v3, v4)
  | `Impo_decl (v1, v2, v3, v4, v5) ->
      let v1 = token env v1 (* "import" *) in
      let v2 =
        (match v2 with
        | Some tok -> token env tok (* "static" *)
        | None -> todo env ())
      in
      let v3 =
        (match v3 with
        | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
        | `Choice_open x ->
            (match x with
            | `Open tok -> token env tok (* "open" *)
            | `Modu tok -> token env tok (* "module" *)
            )
        | `Scop_id x -> scoped_identifier env x
        )
      in
      let v4 =
        (match v4 with
        | Some (v1, v2) ->
            let v1 = token env v1 (* "." *) in
            let v2 = token env v2 (* "*" *) in
            todo env (v1, v2)
        | None -> todo env ())
      in
      let v5 = token env v5 (* ";" *) in
      todo env (v1, v2, v3, v4, v5)
  | `Class_decl x -> class_declaration env x
  | `Inte_decl x -> interface_declaration env x
  | `Anno_type_decl x -> annotation_type_declaration env x
  | `Enum_decl x -> enum_declaration env x
  )


and enum_declaration (env : env) ((v1, v2, v3, v4, v5) : CST.enum_declaration) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = token env v2 (* "enum" *) in
  let v3 = token env v3 (* pattern [a-zA-Z_]\w* *) in
  let v4 =
    (match v4 with
    | Some x -> super_interfaces env x
    | None -> todo env ())
  in
  let v5 = enum_body env v5 in
  todo env (v1, v2, v3, v4, v5)


and enum_body (env : env) ((v1, v2, v3, v4, v5) : CST.enum_body) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    (match v2 with
    | Some (v1, v2) ->
        let v1 = enum_constant env v1 in
        let v2 =
          List.map (fun (v1, v2) ->
            let v1 = token env v1 (* "," *) in
            let v2 = enum_constant env v2 in
            todo env (v1, v2)
          ) v2
        in
        todo env (v1, v2)
    | None -> todo env ())
  in
  let v3 =
    (match v3 with
    | Some tok -> token env tok (* "," *)
    | None -> todo env ())
  in
  let v4 =
    (match v4 with
    | Some x -> enum_body_declarations env x
    | None -> todo env ())
  in
  let v5 = token env v5 (* "}" *) in
  todo env (v1, v2, v3, v4, v5)


and enum_body_declarations (env : env) ((v1, v2) : CST.enum_body_declarations) =
  let v1 = token env v1 (* ";" *) in
  let v2 =
    List.map (fun x ->
      (match x with
      | `Field_decl x -> field_declaration env x
      | `Meth_decl x -> method_declaration env x
      | `Class_decl x -> class_declaration env x
      | `Inte_decl x -> interface_declaration env x
      | `Anno_type_decl x -> annotation_type_declaration env x
      | `Enum_decl x -> enum_declaration env x
      | `Blk x -> block env x
      | `Stat_init x -> static_initializer env x
      | `Cons_decl x -> constructor_declaration env x
      | `SEMI tok -> token env tok (* ";" *)
      )
    ) v2
  in
  todo env (v1, v2)


and enum_constant (env : env) ((v1, v2, v3, v4) : CST.enum_constant) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = token env v2 (* pattern [a-zA-Z_]\w* *) in
  let v3 =
    (match v3 with
    | Some x -> argument_list env x
    | None -> todo env ())
  in
  let v4 =
    (match v4 with
    | Some x -> class_body env x
    | None -> todo env ())
  in
  todo env (v1, v2, v3, v4)


and class_declaration (env : env) ((v1, v2, v3, v4, v5, v6, v7) : CST.class_declaration) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = token env v2 (* "class" *) in
  let v3 = token env v3 (* pattern [a-zA-Z_]\w* *) in
  let v4 =
    (match v4 with
    | Some x -> type_parameters env x
    | None -> todo env ())
  in
  let v5 =
    (match v5 with
    | Some x -> superclass env x
    | None -> todo env ())
  in
  let v6 =
    (match v6 with
    | Some x -> super_interfaces env x
    | None -> todo env ())
  in
  let v7 = class_body env v7 in
  todo env (v1, v2, v3, v4, v5, v6, v7)


and modifiers (env : env) (xs : CST.modifiers) =
  List.map (fun x ->
    (match x with
    | `Anno x -> annotation env x
    | `Publ tok -> token env tok (* "public" *)
    | `Prot tok -> token env tok (* "protected" *)
    | `Priv tok -> token env tok (* "private" *)
    | `Abst tok -> token env tok (* "abstract" *)
    | `Stat tok -> token env tok (* "static" *)
    | `Final tok -> token env tok (* "final" *)
    | `Stri tok -> token env tok (* "strictfp" *)
    | `Defa tok -> token env tok (* "default" *)
    | `Sync tok -> token env tok (* "synchronized" *)
    | `Nati tok -> token env tok (* "native" *)
    | `Tran tok -> token env tok (* "transient" *)
    | `Vola tok -> token env tok (* "volatile" *)
    )
  ) xs


and type_parameters (env : env) ((v1, v2, v3, v4) : CST.type_parameters) =
  let v1 = token env v1 (* "<" *) in
  let v2 = type_parameter env v2 in
  let v3 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = type_parameter env v2 in
      todo env (v1, v2)
    ) v3
  in
  let v4 = token env v4 (* ">" *) in
  todo env (v1, v2, v3, v4)


and type_parameter (env : env) ((v1, v2, v3) : CST.type_parameter) =
  let v1 = List.map (annotation env) v1 in
  let v2 = token env v2 (* pattern [a-zA-Z_]\w* *) in
  let v3 =
    (match v3 with
    | Some x -> type_bound env x
    | None -> todo env ())
  in
  todo env (v1, v2, v3)


and type_bound (env : env) ((v1, v2, v3) : CST.type_bound) =
  let v1 = token env v1 (* "extends" *) in
  let v2 = type_ env v2 in
  let v3 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "&" *) in
      let v2 = type_ env v2 in
      todo env (v1, v2)
    ) v3
  in
  todo env (v1, v2, v3)


and superclass (env : env) ((v1, v2) : CST.superclass) =
  let v1 = token env v1 (* "extends" *) in
  let v2 = type_ env v2 in
  todo env (v1, v2)


and super_interfaces (env : env) ((v1, v2) : CST.super_interfaces) =
  let v1 = token env v1 (* "implements" *) in
  let v2 = interface_type_list env v2 in
  todo env (v1, v2)


and interface_type_list (env : env) ((v1, v2) : CST.interface_type_list) =
  let v1 = type_ env v1 in
  let v2 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = type_ env v2 in
      todo env (v1, v2)
    ) v2
  in
  todo env (v1, v2)


and class_body (env : env) ((v1, v2, v3) : CST.class_body) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    List.map (fun x ->
      (match x with
      | `Field_decl x -> field_declaration env x
      | `Meth_decl x -> method_declaration env x
      | `Class_decl x -> class_declaration env x
      | `Inte_decl x -> interface_declaration env x
      | `Anno_type_decl x -> annotation_type_declaration env x
      | `Enum_decl x -> enum_declaration env x
      | `Blk x -> block env x
      | `Stat_init x -> static_initializer env x
      | `Cons_decl x -> constructor_declaration env x
      | `SEMI tok -> token env tok (* ";" *)
      )
    ) v2
  in
  let v3 = token env v3 (* "}" *) in
  todo env (v1, v2, v3)


and static_initializer (env : env) ((v1, v2) : CST.static_initializer) =
  let v1 = token env v1 (* "static" *) in
  let v2 = block env v2 in
  todo env (v1, v2)


and constructor_declaration (env : env) ((v1, v2, v3, v4) : CST.constructor_declaration) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = constructor_declarator env v2 in
  let v3 =
    (match v3 with
    | Some x -> throws env x
    | None -> todo env ())
  in
  let v4 = constructor_body env v4 in
  todo env (v1, v2, v3, v4)


and constructor_declarator (env : env) ((v1, v2, v3) : CST.constructor_declarator) =
  let v1 =
    (match v1 with
    | Some x -> type_parameters env x
    | None -> todo env ())
  in
  let v2 = token env v2 (* pattern [a-zA-Z_]\w* *) in
  let v3 = formal_parameters env v3 in
  todo env (v1, v2, v3)


and constructor_body (env : env) ((v1, v2, v3, v4) : CST.constructor_body) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    (match v2 with
    | Some x -> explicit_constructor_invocation env x
    | None -> todo env ())
  in
  let v3 = List.map (statement env) v3 in
  let v4 = token env v4 (* "}" *) in
  todo env (v1, v2, v3, v4)


and explicit_constructor_invocation (env : env) ((v1, v2, v3) : CST.explicit_constructor_invocation) =
  let v1 =
    (match v1 with
    | `Opt_type_args_choice_this (v1, v2) ->
        let v1 =
          (match v1 with
          | Some x -> type_arguments env x
          | None -> todo env ())
        in
        let v2 =
          (match v2 with
          | `This tok -> token env tok (* "this" *)
          | `Super tok -> token env tok (* "super" *)
          )
        in
        todo env (v1, v2)
    | `Choice_prim_DOT_opt_type_args_super (v1, v2, v3, v4) ->
        let v1 =
          (match v1 with
          | `Prim x -> primary env x
          )
        in
        let v2 = token env v2 (* "." *) in
        let v3 =
          (match v3 with
          | Some x -> type_arguments env x
          | None -> todo env ())
        in
        let v4 = token env v4 (* "super" *) in
        todo env (v1, v2, v3, v4)
    )
  in
  let v2 = argument_list env v2 in
  let v3 = token env v3 (* ";" *) in
  todo env (v1, v2, v3)


and field_declaration (env : env) ((v1, v2, v3, v4) : CST.field_declaration) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = unannotated_type env v2 in
  let v3 = variable_declarator_list env v3 in
  let v4 = token env v4 (* ";" *) in
  todo env (v1, v2, v3, v4)


and annotation_type_declaration (env : env) ((v1, v2, v3, v4) : CST.annotation_type_declaration) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = token env v2 (* "@interface" *) in
  let v3 = token env v3 (* pattern [a-zA-Z_]\w* *) in
  let v4 = annotation_type_body env v4 in
  todo env (v1, v2, v3, v4)


and annotation_type_body (env : env) ((v1, v2, v3) : CST.annotation_type_body) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    List.map (fun x ->
      (match x with
      | `Anno_type_elem_decl x ->
          annotation_type_element_declaration env x
      | `Cst_decl x -> constant_declaration env x
      | `Class_decl x -> class_declaration env x
      | `Inte_decl x -> interface_declaration env x
      | `Anno_type_decl x -> annotation_type_declaration env x
      )
    ) v2
  in
  let v3 = token env v3 (* "}" *) in
  todo env (v1, v2, v3)


and annotation_type_element_declaration (env : env) ((v1, v2, v3, v4, v5, v6, v7, v8) : CST.annotation_type_element_declaration) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = unannotated_type env v2 in
  let v3 = token env v3 (* pattern [a-zA-Z_]\w* *) in
  let v4 = token env v4 (* "(" *) in
  let v5 = token env v5 (* ")" *) in
  let v6 =
    (match v6 with
    | Some x -> dimensions env x
    | None -> todo env ())
  in
  let v7 =
    (match v7 with
    | Some x -> default_value env x
    | None -> todo env ())
  in
  let v8 = token env v8 (* ";" *) in
  todo env (v1, v2, v3, v4, v5, v6, v7, v8)


and default_value (env : env) ((v1, v2) : CST.default_value) =
  let v1 = token env v1 (* "default" *) in
  let v2 = element_value env v2 in
  todo env (v1, v2)


and interface_declaration (env : env) ((v1, v2, v3, v4, v5, v6) : CST.interface_declaration) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = token env v2 (* "interface" *) in
  let v3 = token env v3 (* pattern [a-zA-Z_]\w* *) in
  let v4 =
    (match v4 with
    | Some x -> type_parameters env x
    | None -> todo env ())
  in
  let v5 =
    (match v5 with
    | Some x -> extends_interfaces env x
    | None -> todo env ())
  in
  let v6 = interface_body env v6 in
  todo env (v1, v2, v3, v4, v5, v6)


and extends_interfaces (env : env) ((v1, v2) : CST.extends_interfaces) =
  let v1 = token env v1 (* "extends" *) in
  let v2 = interface_type_list env v2 in
  todo env (v1, v2)


and interface_body (env : env) ((v1, v2, v3) : CST.interface_body) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    List.map (fun x ->
      (match x with
      | `Cst_decl x -> constant_declaration env x
      | `Enum_decl x -> enum_declaration env x
      | `Meth_decl x -> method_declaration env x
      | `Class_decl x -> class_declaration env x
      | `Inte_decl x -> interface_declaration env x
      | `Anno_type_decl x -> annotation_type_declaration env x
      | `SEMI tok -> token env tok (* ";" *)
      )
    ) v2
  in
  let v3 = token env v3 (* "}" *) in
  todo env (v1, v2, v3)


and constant_declaration (env : env) ((v1, v2, v3, v4) : CST.constant_declaration) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = unannotated_type env v2 in
  let v3 = variable_declarator_list env v3 in
  let v4 = token env v4 (* ";" *) in
  todo env (v1, v2, v3, v4)


and variable_declarator_list (env : env) ((v1, v2) : CST.variable_declarator_list) =
  let v1 = variable_declarator env v1 in
  let v2 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = variable_declarator env v2 in
      todo env (v1, v2)
    ) v2
  in
  todo env (v1, v2)


and variable_declarator (env : env) ((v1, v2) : CST.variable_declarator) =
  let v1 = variable_declarator_id env v1 in
  let v2 =
    (match v2 with
    | Some (v1, v2) ->
        let v1 = token env v1 (* "=" *) in
        let v2 =
          (match v2 with
          | `Exp x -> expression env x
          | `Array_init x -> array_initializer env x
          )
        in
        todo env (v1, v2)
    | None -> todo env ())
  in
  todo env (v1, v2)


and variable_declarator_id (env : env) ((v1, v2) : CST.variable_declarator_id) =
  let v1 =
    (match v1 with
    | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
    | `Choice_open x ->
        (match x with
        | `Open tok -> token env tok (* "open" *)
        | `Modu tok -> token env tok (* "module" *)
        )
    )
  in
  let v2 =
    (match v2 with
    | Some x -> dimensions env x
    | None -> todo env ())
  in
  todo env (v1, v2)


and array_initializer (env : env) ((v1, v2, v3, v4) : CST.array_initializer) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    (match v2 with
    | Some (v1, v2) ->
        let v1 =
          (match v1 with
          | `Exp x -> expression env x
          | `Array_init x -> array_initializer env x
          )
        in
        let v2 =
          List.map (fun (v1, v2) ->
            let v1 = token env v1 (* "," *) in
            let v2 =
              (match v2 with
              | `Exp x -> expression env x
              | `Array_init x -> array_initializer env x
              )
            in
            todo env (v1, v2)
          ) v2
        in
        todo env (v1, v2)
    | None -> todo env ())
  in
  let v3 =
    (match v3 with
    | Some tok -> token env tok (* "," *)
    | None -> todo env ())
  in
  let v4 = token env v4 (* "}" *) in
  todo env (v1, v2, v3, v4)


and type_ (env : env) (x : CST.type_) =
  (match x with
  | `Type_unan_type x -> unannotated_type env x
  | `Type_anno_type (v1, v2) ->
      let v1 = List.map (annotation env) v1 in
      let v2 = unannotated_type env v2 in
      todo env (v1, v2)
  )


and unannotated_type (env : env) (x : CST.unannotated_type) =
  (match x with
  | `Unan_type_choice_void_type x ->
      (match x with
      | `Void_type tok -> token env tok (* "void" *)
      | `Inte_type x -> integral_type env x
      | `Floa_point_type x -> floating_point_type env x
      | `Bool_type tok -> token env tok (* "boolean" *)
      | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
      | `Scop_type_id x -> scoped_type_identifier env x
      | `Gene_type x -> generic_type env x
      )
  | `Unan_type_array_type (v1, v2) ->
      let v1 = unannotated_type env v1 in
      let v2 = dimensions env v2 in
      todo env (v1, v2)
  )


and scoped_type_identifier (env : env) ((v1, v2, v3, v4) : CST.scoped_type_identifier) =
  let v1 =
    (match v1 with
    | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
    | `Scop_type_id x -> scoped_type_identifier env x
    | `Gene_type x -> generic_type env x
    )
  in
  let v2 = token env v2 (* "." *) in
  let v3 = List.map (annotation env) v3 in
  let v4 = token env v4 (* pattern [a-zA-Z_]\w* *) in
  todo env (v1, v2, v3, v4)


and generic_type (env : env) ((v1, v2) : CST.generic_type) =
  let v1 =
    (match v1 with
    | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
    | `Scop_type_id x -> scoped_type_identifier env x
    )
  in
  let v2 = type_arguments env v2 in
  todo env (v1, v2)


and method_header (env : env) ((v1, v2, v3, v4) : CST.method_header) =
  let v1 =
    (match v1 with
    | Some (v1, v2) ->
        let v1 = type_parameters env v1 in
        let v2 = List.map (annotation env) v2 in
        todo env (v1, v2)
    | None -> todo env ())
  in
  let v2 = unannotated_type env v2 in
  let v3 = method_declarator env v3 in
  let v4 =
    (match v4 with
    | Some x -> throws env x
    | None -> todo env ())
  in
  todo env (v1, v2, v3, v4)


and method_declarator (env : env) ((v1, v2, v3) : CST.method_declarator) =
  let v1 =
    (match v1 with
    | `Id tok -> token env tok (* pattern [a-zA-Z_]\w* *)
    | `Choice_open x ->
        (match x with
        | `Open tok -> token env tok (* "open" *)
        | `Modu tok -> token env tok (* "module" *)
        )
    )
  in
  let v2 = formal_parameters env v2 in
  let v3 =
    (match v3 with
    | Some x -> dimensions env x
    | None -> todo env ())
  in
  todo env (v1, v2, v3)


and formal_parameters (env : env) ((v1, v2, v3, v4) : CST.formal_parameters) =
  let v1 = token env v1 (* "(" *) in
  let v2 =
    (match v2 with
    | Some x -> receiver_parameter env x
    | None -> todo env ())
  in
  let v3 =
    (match v3 with
    | Some (v1, v2) ->
        let v1 =
          (match v1 with
          | `Form_param x -> formal_parameter env x
          | `Spre_param x -> spread_parameter env x
          )
        in
        let v2 =
          List.map (fun (v1, v2) ->
            let v1 = token env v1 (* "," *) in
            let v2 =
              (match v2 with
              | `Form_param x -> formal_parameter env x
              | `Spre_param x -> spread_parameter env x
              )
            in
            todo env (v1, v2)
          ) v2
        in
        todo env (v1, v2)
    | None -> todo env ())
  in
  let v4 = token env v4 (* ")" *) in
  todo env (v1, v2, v3, v4)


and formal_parameter (env : env) ((v1, v2, v3) : CST.formal_parameter) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = unannotated_type env v2 in
  let v3 = variable_declarator_id env v3 in
  todo env (v1, v2, v3)


and receiver_parameter (env : env) ((v1, v2, v3, v4) : CST.receiver_parameter) =
  let v1 = List.map (annotation env) v1 in
  let v2 = unannotated_type env v2 in
  let v3 =
    (match v3 with
    | Some (v1, v2) ->
        let v1 = token env v1 (* pattern [a-zA-Z_]\w* *) in
        let v2 = token env v2 (* "." *) in
        todo env (v1, v2)
    | None -> todo env ())
  in
  let v4 = token env v4 (* "this" *) in
  todo env (v1, v2, v3, v4)


and spread_parameter (env : env) ((v1, v2, v3, v4) : CST.spread_parameter) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = unannotated_type env v2 in
  let v3 = token env v3 (* "..." *) in
  let v4 = variable_declarator env v4 in
  todo env (v1, v2, v3, v4)


and throws (env : env) ((v1, v2, v3) : CST.throws) =
  let v1 = token env v1 (* "throws" *) in
  let v2 = type_ env v2 in
  let v3 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = type_ env v2 in
      todo env (v1, v2)
    ) v3
  in
  todo env (v1, v2, v3)


and local_variable_declaration (env : env) ((v1, v2, v3, v4) : CST.local_variable_declaration) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = unannotated_type env v2 in
  let v3 = variable_declarator_list env v3 in
  let v4 = token env v4 (* ";" *) in
  todo env (v1, v2, v3, v4)


and method_declaration (env : env) ((v1, v2, v3) : CST.method_declaration) =
  let v1 =
    (match v1 with
    | Some x -> modifiers env x
    | None -> todo env ())
  in
  let v2 = method_header env v2 in
  let v3 =
    (match v3 with
    | `Blk x -> block env x
    | `SEMI tok -> token env tok (* ";" *)
    )
  in
  todo env (v1, v2, v3)

let program (env : env) (xs : CST.program) =
  List.map (statement env) xs


let parse file =
  let cst =
    Parallel.backtrace_when_exn := false;
    Parallel.invoke Tree_sitter_java.Parse.file file ()
  in
  (* TODO *)
  raise Todo
