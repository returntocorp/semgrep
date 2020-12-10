(* PUT YOUR NAME HERE
 *
 * Copyright (c) PUT YOUR COPYRIGHT HERE
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
module CST = Tree_sitter_kotlin.CST
module AST = AST_generic
module H = Parse_tree_sitter_helpers
module PI = Parse_info
open AST_generic

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* kotlin parser using ocaml-tree-sitter-lang/kotlin and converting
 * directly to pfff/h_program-lang/ast_generic.ml
 *
*)

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)
type env = unit H.env
let _fake = AST_generic.fake
let token = H.token
let str = H.str
let fb = fake_bracket
let sc = PI.fake_info ";"

(*****************************************************************************)
(* Boilerplate converter *)
(*****************************************************************************)
(* This was started by copying ocaml-tree-sitter-lang/kotlin/Boilerplate.ml *)

(**
   Boilerplate to be used as a template when mapping the kotlin CST
   to another type of tree.
*)

(* Disable warnings against unused variables *)
[@@@warning "-26-27"]

(* Disable warning against unused 'rec' *)
[@@@warning "-39"]

(* TODO: FIX!! Disable warning against unused value *)
[@@@warning "-32"]

let blank (env : env) () =
  failwith "not implemented"

let todo (env : env) _ =
  failwith "not implemented"

let token_todo (env : env) _ =
  failwith "token Todo"

let escaped_identifier (env : env) (tok : CST.escaped_identifier) =
  token env tok (* pattern "\\\\[tbrn'\dq\\\\$]" *)

let pat_b294348 (env : env) (tok : CST.pat_b294348) =
  token env tok (* pattern "[^\\n\\r'\\\\]" *)

let visibility_modifier (env : env) (x : CST.visibility_modifier) =
  (match x with
   | `Public tok -> token env tok (* "public" *)
   | `Priv tok -> token env tok (* "private" *)
   | `Inte tok -> token env tok (* "internal" *)
   | `Prot tok -> token env tok (* "protected" *)
  )

let equality_operator (env : env) (x : CST.equality_operator) =
  (match x with
   | `BANGEQ tok -> NotEq, token env tok (* "!=" *)
   | `BANGEQEQ tok -> NotPhysEq, token env tok (* "!==" *)
   | `EQEQ tok -> Eq, token env tok (* "==" *)
   | `EQEQEQ tok -> PhysEq, token env tok (* "===" *)
  )

let multi_line_str_text (env : env) (tok : CST.multi_line_str_text) =
  token env tok (* pattern "[^\dq$]+" *)

let pat_a2e2132 (env : env) (tok : CST.pat_a2e2132) =
  token env tok (* pattern [0-9a-fA-F]{4} *)

let pat_c793459 (env : env) (tok : CST.pat_c793459) =
  token env tok (* pattern [uU] *)

let anon_choice_val_2833752 (env : env) (x : CST.anon_choice_val_2833752) =
  (match x with
   | `Val tok -> token env tok (* "val" *)
   | `Var tok -> token env tok (* "var" *)
  )

let platform_modifier (env : env) (x : CST.platform_modifier) =
  (match x with
   | `Expect tok -> token env tok (* "expect" *)
   | `Actual tok -> token env tok (* "actual" *)
  )

let label (env : env) (tok : CST.label) =
  token env tok (* label *)

let real_literal (env : env) (tok : CST.real_literal) =
  Float (str env tok) (* real_literal *)

let comparison_operator (env : env) (x : CST.comparison_operator) =
  (match x with
   | `LT tok ->Lt, token env tok (* "<" *)
   | `GT tok -> Gt, token env tok (* ">" *)
   | `LTEQ tok -> LtE, token env tok (* "<=" *)
   | `GTEQ tok -> GtE, token env tok (* ">=" *)
  )

let assignment_and_operator (env : env) (x : CST.assignment_and_operator) =
  (match x with
   | `PLUSEQ tok -> token env tok (* "+=" *)
   | `DASHEQ tok -> token env tok (* "-=" *)
   | `STAREQ tok -> token env tok (* "*=" *)
   | `SLASHEQ tok -> token env tok (* "/=" *)
   | `PERCEQ tok -> token env tok (* "%=" *)
  )

let inheritance_modifier (env : env) (x : CST.inheritance_modifier) =
  (match x with
   | `Abst tok -> token env tok (* "abstract" *)
   | `Final tok -> token env tok (* "final" *)
   | `Open tok -> token env tok (* "open" *)
  )

let postfix_unary_operator (env : env) (x : CST.postfix_unary_operator) =
  (match x with
   | `PLUSPLUS tok -> Left Incr, token env tok (* "++" *)
   | `DASHDASH tok -> Left Decr, token env tok (* "--" *)
   | `BANGBANG tok -> Right NotNullPostfix, token env tok (* "!!" *)
  )

let variance_modifier (env : env) (x : CST.variance_modifier) =
  (match x with
   | `In tok -> token env tok (* "in" *)
   | `Out tok -> token env tok (* "out" *)
  )

let member_modifier (env : env) (x : CST.member_modifier) =
  (match x with
   | `Over tok -> token env tok (* "override" *)
   | `Late tok -> token env tok (* "lateinit" *)
  )

let class_modifier (env : env) (x : CST.class_modifier) =
  (match x with
   | `Sealed tok -> token env tok (* "sealed" *)
   | `Anno tok -> token env tok (* "annotation" *)
   | `Data tok -> token env tok (* "data" *)
   | `Inner tok -> token env tok (* "inner" *)
  )

let boolean_literal (env : env) (x : CST.boolean_literal) =
  (match x with
   | `True tok -> Bool (true, token env tok) (* "true" *)
   | `False tok -> Bool (false, token env tok) (* "false" *)
  )

let hex_literal (env : env) (tok : CST.hex_literal) =
  Int (str env tok) (* hex_literal *)

let pat_f630af3 (env : env) (tok : CST.pat_f630af3) =
  token env tok (* pattern [^\r\n]* *)

let use_site_target (env : env) ((v1, v2) : CST.use_site_target) =
  let v1 =
    (match v1 with
     | `Field tok -> token env tok (* "field" *)
     | `Prop tok -> token env tok (* "property" *)
     | `Get tok -> token env tok (* "get" *)
     | `Set tok -> token env tok (* "set" *)
     | `Rece tok -> token env tok (* "receiver" *)
     | `Param tok -> token env tok (* "param" *)
     | `Setp tok -> token env tok (* "setparam" *)
     | `Dele tok -> token env tok (* "delegate" *)
    )
  in
  let v2 = token env v2 (* ":" *) in
  v1

let additive_operator (env : env) (x : CST.additive_operator) =
  (match x with
   | `PLUS tok -> Plus, token env tok (* "+" *)
   | `DASH tok -> Minus, token env tok (* "-" *)
  )

let integer_literal (env : env) (tok : CST.integer_literal) =
  Int (str env tok) (* integer_literal *)

let pat_ddcb2a5 (env : env) (tok : CST.pat_ddcb2a5) =
  token env tok (* pattern [a-zA-Z_][a-zA-Z_0-9]* *)

let semis (env : env) (tok : CST.semis) =
  token env tok (* pattern [\r\n]+ *)

let as_operator (env : env) (x : CST.as_operator) =
  (match x with
   | `As tok -> token env tok (* "as" *)
   | `AsQM tok -> token env tok (* "as?" *)
  )

let function_modifier (env : env) (x : CST.function_modifier) =
  (match x with
   | `Tail tok -> token env tok (* "tailrec" *)
   | `Op tok -> token env tok (* "operator" *)
   | `Infix tok -> token env tok (* "infix" *)
   | `Inline tok -> token env tok (* "inline" *)
   | `Exte tok -> token env tok (* "external" *)
   | `Susp tok -> token env tok (* "suspend" *)
  )

let line_str_text (env : env) (tok : CST.line_str_text) =
  token env tok (* pattern "[^\\\\\double_quote$]+" *)

let semi (env : env) (tok : CST.semi) =
  token env tok (* pattern [\r\n]+ *)

let prefix_unary_operator (env : env) (x : CST.prefix_unary_operator) =
  match x with
  | `PLUSPLUS tok -> Left Incr, token env tok (* "++" *)
  | `DASHDASH tok ->Left Decr, token env tok (* "--" *)
  | `DASH tok -> Right Minus, token env tok (* "-" *)
  | `PLUS tok -> Right Plus, token env tok (* "+" *)
  | `BANG tok -> Right Not, token env tok (* "!" *)

let in_operator (env : env) (x : CST.in_operator) =
  (match x with
   | `In tok -> In, token env tok (* "in" *)
   | `BANGin tok -> NotIn, token env tok (* "!in" *)
  )

let multiplicative_operator (env : env) (x : CST.multiplicative_operator) =
  (match x with
   | `STAR tok -> Mult, token env tok (* "*" *)
   | `SLASH tok -> Div, token env tok (* "/" *)
   | `PERC tok -> Mod, token env tok (* "%" *)
  )

let parameter_modifier (env : env) (x : CST.parameter_modifier) =
  (match x with
   | `Vararg tok -> token env tok (* "vararg" *)
   | `Noin tok -> token env tok (* "noinline" *)
   | `Cros tok -> token env tok (* "crossinline" *)
  )

let bin_literal (env : env) (tok : CST.bin_literal) =
  Int (str env tok) (* bin_literal *)

let pat_b9a3713 (env : env) (tok : CST.pat_b9a3713) =
  token env tok (* pattern `[^\r\n`]+` *)

let multi_line_string_content (env : env) (x : CST.multi_line_string_content) =
  (match x with
   | `Multi_line_str_text tok ->
       token env tok (* pattern "[^\"$]+" *)
   | `DQUOT tok -> token env tok (* "\"" *)
  )

let uni_character_literal (env : env) ((v1, v2, v3) : CST.uni_character_literal) =
  let v1 = str env v1 (* "\\" *) in
  let v2 = str env v2 (* "u" *) in
  let v3 = str env v3 (* pattern [0-9a-fA-F]{4} *) in
  fst v3, PI.combine_infos (snd v1) [snd v3]

let type_projection_modifier (env : env) (x : CST.type_projection_modifier) =
  let _ = variance_modifier env x in
  raise Todo

let shebang_line (env : env) ((v1, v2) : CST.shebang_line) =
  let v1 = token env v1 (* "#!" *) in
  let v2 = token env v2 (* pattern [^\r\n]* *) in
  todo env (v1, v2)

let is_operator (env : env) (x : CST.is_operator) =
  (match x with
   | `Is tok -> Is, token env tok (* "is" *)
   | `Not_is tok -> NotIs, token env tok (* "!is" *)
  )

let modifier (env : env) (x : CST.modifier) =
  (match x with
   | `Class_modi x -> class_modifier env x
   | `Member_modi x -> member_modifier env x
   | `Visi_modi x -> visibility_modifier env x
   | `Func_modi x -> function_modifier env x
   | `Prop_modi tok -> token env tok (* "const" *)
   | `Inhe_modi x -> inheritance_modifier env x
   | `Param_modi x -> parameter_modifier env x
   | `Plat_modi x -> platform_modifier env x
  )

let member_access_operator (env : env) (x : CST.member_access_operator) =
  (match x with
   | `DOT tok -> token env tok (* "." *)
   | `Safe_nav tok -> token env tok (* "?." *)
   | `COLONCOLON tok -> token env tok (* "::" *)
  )

let anon_choice_int_lit_9015f32 (env : env) (x : CST.anon_choice_int_lit_9015f32) : string wrap =
  (match x with
   | `Int_lit tok -> str env tok (* integer_literal *)
   | `Hex_lit tok -> str env tok (* hex_literal *)
   | `Bin_lit tok -> str env tok (* bin_literal *)
  )

let lexical_identifier (env : env) (x : CST.lexical_identifier) : ident =
  (match x with
   | `Pat_ddcb2a5 tok ->
       str env tok (* pattern [a-zA-Z_][a-zA-Z_0-9]* *)
   | `Pat_b9a3713 tok ->
       str env tok (* pattern `[^\r\n`]+` *)
  )

let escape_seq (env : env) (x : CST.escape_seq) =
  (match x with
   | `Uni_char_lit x -> uni_character_literal env x
   | `Esca_id tok ->
       str env tok (* pattern "\\\\[tbrn'\dq\\\\$]" *)
  )

let line_str_escaped_char (env : env) (x : CST.line_str_escaped_char) =
  (match x with
   | `Esca_id tok ->
       str env tok (* pattern "\\\\[tbrn'\dq\\\\$]" *)
   | `Uni_char_lit x -> uni_character_literal env x
  )

let type_projection_modifiers (env : env) (xs : CST.type_projection_modifiers) =
  List.map (type_projection_modifier env) xs

let simple_identifier (env : env) (x : CST.simple_identifier) : ident =
  lexical_identifier env x

let line_string_content (env : env) (x : CST.line_string_content) =
  (match x with
   | `Line_str_text tok ->
       str env tok (* pattern "[^\\\\\double_quote$]+" *)
   | `Line_str_esca_char x -> line_str_escaped_char env x
  )

let return_at (env : env) ((v1, v2) : CST.return_at) =
  let v1 = token env v1 (* "return@" *) in
  let v2 = simple_identifier env v2 in
  (v1, Some v2)

let identifier (env : env) ((v1, v2) : CST.identifier) =
  let v1 = simple_identifier env v1 in
  let v2 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "." *) in
      let v2 = simple_identifier env v2 in
      todo env (v1, v2)
    ) v2
  in
  todo env (v1, v2)

let directly_assignable_expression (env : env) (x : CST.directly_assignable_expression) =
  (match x with
   | `Simple_id x -> simple_identifier env x
  )

let import_alias (env : env) ((v1, v2) : CST.import_alias) =
  let v1 = token env v1 (* "as" *) in
  let v2 = simple_identifier env v2 in
  todo env (v1, v2)

let literal_constant (env : env) (x : CST.literal_constant) =
  match x with
  | `Bool_lit x -> boolean_literal env x
  | `Int_lit tok -> integer_literal env tok (* integer_literal *)
  | `Hex_lit tok -> hex_literal env tok (* hex_literal *)
  | `Bin_lit tok -> bin_literal env tok (* bin_literal *)
  | `Char_lit (v1, v2, v3) ->
      let v1 = token env v1 (* "'" *) in
      let v2 =
        (match v2 with
         | `Esc_seq x -> escape_seq env x
         | `Pat_b294348 tok ->
             str env tok (* pattern "[^\\n\\r'\\\\]" *)
        )
      in
      let v3 = token env v3 (* "'" *) in
      let toks = [snd v2] @ [v3] in
      Char (fst v2, PI.combine_infos v1 toks)
  | `Real_lit tok -> real_literal env tok (* real_literal *)
  | `Null tok -> Null (token env tok) (* "null" *)
  | `Long_lit (v1, v2) ->
      let v1 = anon_choice_int_lit_9015f32 env v1 in
      let v2 = token env v2 (* "L" *) in
      Int (fst v1, snd v1)
  | `Unsi_lit (v1, v2, v3) ->
      let v1 = anon_choice_int_lit_9015f32 env v1 in
      let v2 = str env v2 (* pattern [uU] *) in
      let v3 =
        (match v3 with
         | Some tok -> Some (str env tok) (* "L" *)
         | None -> None)
      in
      let xs = [v1;v2] in
      let str = xs |> List.map fst |> String.concat "" in
      Int (str, PI.combine_infos (snd v1) [snd v2])

let package_header (env : env) ((v1, v2, v3) : CST.package_header) =
  let v1 = token env v1 (* "package" *) in
  let v2 = identifier env v2 in
  let v3 = token env v3 (* pattern [\r\n]+ *) in
  todo env (v1, v2, v3)

let import_header (env : env) ((v1, v2, v3, v4) : CST.import_header) =
  let v1 = token env v1 (* "import" *) in
  let v2 = identifier env v2 in
  let v3 =
    (match v3 with
     | Some x ->
         (match x with
          | `DOTSTAR v1 -> token env v1 (* ".*" *)
          | `Import_alias x -> import_alias env x
         )
     | None -> todo env ())
  in
  let v4 = token env v4 (* pattern [\r\n]+ *) in
  todo env (v1, v2, v3, v4)

let rec annotated_lambda (env : env) (v1 : CST.annotated_lambda) =
  lambda_literal env v1

and annotation (env : env) (x : CST.annotation) =
  (match x with
   | `Single_anno (v1, v2, v3) ->
       let v1 = token env v1 (* "@" *) in
       let v2 =
         (match v2 with
          | Some x -> Some (use_site_target env x)
          | None -> None)
       in
       let v3 = unescaped_annotation env v3 in
       todo env (v1, v2, v3)
   | `Multi_anno (v1, v2, v3, v4, v5) ->
       let v1 = token env v1 (* "@" *) in
       let v2 =
         (match v2 with
          | Some x -> use_site_target env x
          | None -> todo env ())
       in
       let v3 = token env v3 (* "[" *) in
       let v4 = List.map (unescaped_annotation env) v4 in
       let v5 = token env v5 (* "]" *) in
       todo env (v1, v2, v3, v4, v5)
  )

and anon_choice_param_b77c1d8 (env : env) (x : CST.anon_choice_param_b77c1d8) =
  (match x with
   | `Param x -> parameter env x
   | `Type x -> let _ =  type_ env x in
       raise Todo
  )

and assignment (env : env) (x : CST.assignment) =
  (match x with
   | `Dire_assi_exp_assign_and_op_exp (v1, v2, v3) ->
       let v1 = directly_assignable_expression env v1 in
       let v2 = assignment_and_operator env v2 in
       let v3 = expression env v3 in
       todo env (v1, v2, v3)
  )

and binary_expression (env : env) (x : CST.binary_expression) =
  (match x with
   | `Mult_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2, tok = multiplicative_operator env v2 in
       let v3 = expression env v3 in
       Call (IdSpecial (Op (v2), tok), fb[Arg v1; Arg v3])
   | `Addi_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2, tok = additive_operator env v2 in
       let v3 = expression env v3 in
       Call (IdSpecial (Op (v2), tok), fb[Arg v1; Arg v3])
   | `Range_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2, tok = Range, token env v2 (* ".." *) in
       let v3 = expression env v3 in
       Call (IdSpecial (Op (v2), tok), fb[Arg v1; Arg v3])
   | `Infix_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2 = simple_identifier env v2 in
       let v2_id = Id (v2, empty_id_info()) in
       let v3 = expression env v3 in
       Call (v2_id, fb[Arg v1; Arg v3])
   | `Elvis_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2, tok = Elvis, token env v2 (* "?:" *) in
       let v3 = expression env v3 in
       Call (IdSpecial (Op (v2), tok), fb[Arg v1; Arg v3])
   | `Check_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2, tok =
         (match v2 with
          | `In_op x -> in_operator env x
          | `Is_op x -> is_operator env x
         )
       in
       let v3 = expression env v3 in
       Call (IdSpecial (Op (v2), tok), fb[Arg v1; Arg v3])
   | `Comp_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2, tok = comparison_operator env v2 in
       let v3 = expression env v3 in
       Call (IdSpecial (Op (v2), tok), fb[Arg v1; Arg v3])
   | `Equa_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2, tok = equality_operator env v2 in
       let v3 = expression env v3 in
       Call (IdSpecial (Op (v2), tok), fb[Arg v1; Arg v3])
   | `Conj_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2, tok = And, token env v2 (* "&&" *) in
       let v3 = expression env v3 in
       Call (IdSpecial (Op (v2), tok), fb[Arg v1; Arg v3])
   | `Disj_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2, tok = Or, token env v2 (* "||" *) in
       let v3 = expression env v3 in
       Call (IdSpecial (Op (v2), tok), fb[Arg v1; Arg v3])
  )

and block (env : env) ((v1, v2, v3) : CST.block) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    (match v2 with
     | Some x -> statements env x
     | None -> [])
  in
  let v3 = token env v3 (* "}" *) in
  Block (v1, v2, v3)

and call_suffix (env : env) (v1 : CST.call_suffix) =
  (match v1 with
   | `Opt_value_args_anno_lambda (v1, v2) ->
       let v1 =
         (match v1 with
          | Some x -> value_arguments env x
          | None -> fake_bracket [])
       in
       (*let v2 = annotated_lambda env v2 in*)
       v1
   | `Value_args x -> value_arguments env x
  )

and catch_block (env : env) ((v1, v2, v3, v4, v5, v6, v7, v8) : CST.catch_block) =
  let v1 = token env v1 (* "catch" *) in
  let v2 = token env v2 (* "(" *) in
  let v3 = List.map (annotation env) v3 in
  let v4 = simple_identifier env v4 in
  let v5 = token env v5 (* ":" *) in
  let v6 = type_ env v6 in
  let v7 = token env v7 (* ")" *) in
  let v8 = block env v8 in
  let list = [v3] in
  let id = Some(v4, empty_id_info()) in
  let pattern = PatVar (v6, id) in
  (v1, pattern, v8)

and class_body (env : env) ((v1, v2, v3) : CST.class_body) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    (match v2 with
     | Some x -> class_member_declarations env x
     | None -> todo env ())
  in
  let v3 = token env v3 (* "}" *) in
  (v1, v2, v3)

and class_declaration (env : env) (x : CST.class_declaration) =
  (match x with
   | `Opt_modifs_choice_class_simple_id_opt_type_params_opt_prim_cons_opt_COLON_dele_specis_opt_type_consts_opt_class_body (v1, v2, v3, v4, v5, v6, v7, v8) ->
       let v1 =
         (match v1 with
          | Some x -> modifiers env x
          | None -> todo env ())
       in
       let v2 =
         (match v2 with
          | `Class tok -> token env tok (* "class" *)
          | `Inte tok -> token env tok (* "interface" *)
         )
       in
       let v3 = simple_identifier env v3 in
       let v4 =
         (match v4 with
          | Some x -> type_parameters env x
          | None -> todo env ())
       in
       let v5 =
         (match v5 with
          | Some x -> primary_constructor env x
          | None -> todo env ())
       in
       let v6 =
         (match v6 with
          | Some (v1, v2) ->
              let v1 = token env v1 (* ":" *) in
              let v2 = delegation_specifiers env v2 in
              todo env (v1, v2)
          | None -> todo env ())
       in
       let v7 =
         (match v7 with
          | Some x -> type_constraints env x
          | None -> todo env ())
       in
       let v8 =
         (match v8 with
          | Some x -> class_body env x
          | None -> todo env ())
       in
       todo env (v1, v2, v3, v4, v5, v6, v7, v8)
   | `Opt_modifs_enum_class_simple_id_opt_type_params_opt_prim_cons_opt_COLON_dele_specis_opt_type_consts_opt_enum_class_body (v1, v2, v3, v4, v5, v6, v7, v8, v9) ->
       let v1 =
         (match v1 with
          | Some x -> modifiers env x
          | None -> todo env ())
       in
       let v2 = token env v2 (* "enum" *) in
       let v3 = token env v3 (* "class" *) in
       let v4 = simple_identifier env v4 in
       let v5 =
         (match v5 with
          | Some x -> type_parameters env x
          | None -> todo env ())
       in
       let v6 =
         (match v6 with
          | Some x -> primary_constructor env x
          | None -> todo env ())
       in
       let v7 =
         (match v7 with
          | Some (v1, v2) ->
              let v1 = token env v1 (* ":" *) in
              let v2 = delegation_specifiers env v2 in
              todo env (v1, v2)
          | None -> todo env ())
       in
       let v8 =
         (match v8 with
          | Some x -> type_constraints env x
          | None -> todo env ())
       in
       let v9 =
         (match v9 with
          | Some x -> enum_class_body env x
          | None -> todo env ())
       in
       todo env (v1, v2, v3, v4, v5, v6, v7, v8, v9)
  )

and class_member_declaration (env : env) (x : CST.class_member_declaration) =
  (match x with
   | `Decl x -> declaration env x
   | `Comp_obj (v1, v2, v3, v4, v5, v6) ->
       let v1 =
         (match v1 with
          | Some x -> modifiers env x
          | None -> todo env ())
       in
       let v2 = token env v2 (* "companion" *) in
       let v3 = token env v3 (* "object" *) in
       let v4 =
         (match v4 with
          | Some x -> simple_identifier env x
          | None -> todo env ())
       in
       let v5 =
         (match v5 with
          | Some (v1, v2) ->
              let v1 = token env v1 (* ":" *) in
              let v2 = delegation_specifiers env v2 in
              todo env (v1, v2)
          | None -> todo env ())
       in
       let v6 =
         (match v6 with
          | Some x -> class_body env x
          | None -> todo env ())
       in
       todo env (v1, v2, v3, v4, v5, v6)
   | `Anon_init (v1, v2) ->
       let v1 = token env v1 (* "init" *) in
       let v2 = block env v2 in
       todo env (v1, v2)
   | `Seco_cons (v1, v2, v3, v4, v5) ->
       let v1 =
         (match v1 with
          | Some x -> modifiers env x
          | None -> todo env ())
       in
       let v2 = token env v2 (* "constructor" *) in
       let v3 = function_value_parameters env v3 in
       let v4 =
         (match v4 with
          | Some (v1, v2) ->
              let v1 = token env v1 (* ":" *) in
              let v2 = constructor_delegation_call env v2 in
              todo env (v1, v2)
          | None -> todo env ())
       in
       let v5 =
         (match v5 with
          | Some x -> block env x
          | None -> todo env ())
       in
       todo env (v1, v2, v3, v4, v5)
  )

and class_member_declarations (env : env) (xs : CST.class_member_declarations) =
  List.map (fun (v1, v2) ->
    let v1 = class_member_declaration env v1 in
    let v2 = str env v2 (* pattern [\r\n]+ *) in
    todo env (v1, v2)
  ) xs

and class_parameter (env : env) ((v1, v2, v3, v4, v5, v6) : CST.class_parameter) =
  let v1 =
    (match v1 with
     | Some x -> modifiers env x
     | None -> todo env ())
  in
  let v2 =
    (match v2 with
     | Some x -> anon_choice_val_2833752 env x
     | None -> todo env ())
  in
  let v3 = simple_identifier env v3 in
  let v4 = token env v4 (* ":" *) in
  let v5 = type_ env v5 in
  let v6 =
    (match v6 with
     | Some (v1, v2) ->
         let v1 = token env v1 (* "=" *) in
         let v2 = expression env v2 in
         todo env (v1, v2)
     | None -> todo env ())
  in
  todo env (v1, v2, v3, v4, v5, v6)

and class_parameters (env : env) ((v1, v2, v3) : CST.class_parameters) =
  let v1 = token env v1 (* "(" *) in
  let v2 =
    (match v2 with
     | Some (v1, v2) ->
         let v1 = class_parameter env v1 in
         let v2 =
           List.map (fun (v1, v2) ->
             let v1 = token env v1 (* "," *) in
             let v2 = class_parameter env v2 in
             todo env (v1, v2)
           ) v2
         in
         todo env (v1, v2)
     | None -> todo env ())
  in
  let v3 = token env v3 (* ")" *) in
  todo env (v1, v2, v3)

and constructor_delegation_call (env : env) ((v1, v2) : CST.constructor_delegation_call) =
  let v1 =
    (match v1 with
     | `This tok -> token env tok (* "this" *)
     | `Super tok -> token env tok (* "super" *)
    )
  in
  let v2 = value_arguments env v2 in
  todo env (v1, v2)

and constructor_invocation (env : env) ((v1, v2) : CST.constructor_invocation) =
  let v1 = user_type env v1 in
  let v2 = value_arguments env v2 in
  todo env (v1, v2)

and control_structure_body (env : env) (x : CST.control_structure_body) =
  (match x with
   | `Blk x -> block env x
   | `Stmt x -> statement env x
  )

and declaration (env : env) (x : CST.declaration) : definition =
  (match x with
   | `Class_decl x -> class_declaration env x
   | `Obj_decl (v1, v2, v3, v4, v5) ->
       let v1 =
         (match v1 with
          | Some x -> modifiers env x
          | None -> todo env ())
       in
       let v2 = token env v2 (* "object" *) in
       let v3 = simple_identifier env v3 in
       let v4 =
         (match v4 with
          | Some (v1, v2) ->
              let v1 = token env v1 (* ":" *) in
              let v2 = delegation_specifiers env v2 in
              todo env (v1, v2)
          | None -> todo env ())
       in
       let v5 =
         (match v5 with
          | Some x -> class_body env x
          | None -> todo env ())
       in
       todo env (v1, v2, v3, v4, v5)
   | `Func_decl (_v1, _v2, v3, v4, _v5, _v6, _v7, v8) ->
       (*let v1 =
         (match v1 with
         | Some x -> Some (modifiers env x)
         | None -> None)
         in
         let v2 =
         (match v2 with
         | Some x -> Some (type_parameters env x)
         | None -> None)
         in*)
       let tok = token env v3 (* "fun" *) in
       let v3 = Function, tok in
       let v4 = simple_identifier env v4 in
       (*let v5 = function_value_parameters env v5 in
         let v6 =
         (match v6 with
         | Some (v1, v2) ->
             let v1 = token env v1 (* ":" *) in
             let v2 = type_ env v2 in
             todo env (v1, v2)
         | None -> todo env ())
         in
         let v7 =
         (match v7 with
         | Some x -> type_constraints env x
         | None -> todo env ())
         in*)
       let v8 =
         (match v8 with
          | Some x -> function_body env x
          | None -> empty_fbody)
       in
       let entity = basic_entity v4 [] in
       let func_def = {
         fkind =  v3;
         fparams =  [];
         frettype =  None;
         fbody = v8;
       } in
       let def_kind = FuncDef func_def in
       entity, def_kind
   | `Prop_decl (v1, v2, v3, v4, v5, v6, v7) ->
       let v1 =
         (match v1 with
          | Some x -> modifiers env x
          | None -> todo env ())
       in
       let v2 = anon_choice_val_2833752 env v2 in
       let v3 =
         (match v3 with
          | Some x -> type_parameters env x
          | None -> todo env ())
       in
       let v4 = variable_declaration env v4 in
       let v5 =
         (match v5 with
          | Some x -> type_constraints env x
          | None -> todo env ())
       in
       let v6 =
         (match v6 with
          | Some x ->
              (match x with
               | `EQ_exp (v1, v2) ->
                   let v1 = token env v1 (* "=" *) in
                   let v2 = expression env v2 in
                   todo env (v1, v2)
               | `Prop_dele x -> property_delegate env x
              )
          | None -> todo env ())
       in
       let v7 =
         (match v7 with
          | `Opt_getter opt ->
              (match opt with
               | Some x -> getter env x
               | None -> todo env ())
          | `Opt_setter opt ->
              (match opt with
               | Some x -> setter env x
               | None -> todo env ())
         )
       in
       todo env (v1, v2, v3, v4, v5, v6, v7)
   | `Type_alias (v1, v2, v3, v4) ->
       let v1 = token env v1 (* "typealias" *) in
       let v2 = simple_identifier env v2 in
       let v3 = token env v3 (* "=" *) in
       let v4 = type_ env v4 in
       todo env (v1, v2, v3, v4)
  )

and delegation_specifier (env : env) (x : CST.delegation_specifier) =
  (match x with
   | `Cons_invo x -> constructor_invocation env x
   | `Expl_dele (v1, v2, v3) ->
       let v1 =
         (match v1 with
          | `User_type x -> user_type env x
          | `Func_type x -> function_type env x
         )
       in
       let v2 = token env v2 (* "by" *) in
       let v3 = expression env v3 in
       todo env (v1, v2, v3)
   | `User_type x -> user_type env x
   | `Func_type x -> function_type env x
  )

and delegation_specifiers (env : env) ((v1, v2) : CST.delegation_specifiers) =
  let v1 = delegation_specifier env v1 in
  let v2 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = delegation_specifier env v2 in
      v2
    ) v2
  in
  v1::v2

and enum_class_body (env : env) ((v1, v2, v3, v4) : CST.enum_class_body) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    (match v2 with
     | Some x -> enum_entries env x
     | None -> todo env ())
  in
  let v3 =
    (match v3 with
     | Some (v1, v2) ->
         let v1 = token env v1 (* ";" *) in
         let v2 =
           (match v2 with
            | Some x -> class_member_declarations env x
            | None -> todo env ())
         in
         todo env (v1, v2)
     | None -> todo env ())
  in
  let v4 = token env v4 (* "}" *) in
  todo env (v1, v2, v3, v4)

and enum_entries (env : env) ((v1, v2, v3) : CST.enum_entries) =
  let v1 = enum_entry env v1 in
  let v2 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = enum_entry env v2 in
      todo env (v1, v2)
    ) v2
  in
  let v3 =
    (match v3 with
     | Some tok -> token env tok (* "," *)
     | None -> todo env ())
  in
  todo env (v1, v2, v3)

and enum_entry (env : env) ((v1, v2, v3, v4) : CST.enum_entry) =
  let v1 =
    (match v1 with
     | Some x -> modifiers env x
     | None -> todo env ())
  in
  let v2 = simple_identifier env v2 in
  let v3 =
    (match v3 with
     | Some x -> value_arguments env x
     | None -> todo env ())
  in
  let v4 =
    (match v4 with
     | Some x -> class_body env x
     | None -> todo env ())
  in
  todo env (v1, v2, v3, v4)

and expression (env : env) (x : CST.expression) : expr =
  (match x with
   | `Un_exp x -> unary_expression env x
   | `Bin_exp x -> binary_expression env x
   | `Prim_exp x -> primary_expression env x
  )

and finally_block (env : env) ((v1, v2) : CST.finally_block) =
  let v1 = token env v1 (* "finally" *) in
  let v2 = block env v2 in
  (v1, v2)

and function_body (env : env) (x : CST.function_body) =
  (match x with
   | `Blk x -> block env x
   | `EQ_exp (v1, v2) ->
       let v1 = token env v1 (* "=" *) in
       let v2 = expression env v2 in
       ExprStmt (v2, sc)
  )

and function_literal (env : env) (x : CST.function_literal) =
  match x with
  | `Lambda_lit x -> lambda_literal env x
  | `Anon_func (v1, v2, v3, v4, v5) ->
      let v1 = token env v1 (* "fun" *) in
      let v2 =
        (match v2 with
         | Some (v1, v2, v3) ->
             let v1 = simple_user_type env v1 in
             let v2 =
               List.map (fun (v1, v2) ->
                 let v1 = token env v1 (* "." *) in
                 let v2 = simple_user_type env v2 in
                 v2
               ) v2
             in
             let v3 = token env v3 (* "." *) in
             v1::v2
         | None -> [])
      in
      let v3 = token env v3 (* "(" *) in
      let v4 = token env v4 (* ")" *) in
      let v5 =
        (match v5 with
         | Some x -> function_body env x
         | None -> empty_fbody)
      in
      let kind = Function, v1 in
      let func_def = {
        fkind =  kind;
        fparams =  [];
        frettype =  None;
        fbody = v5;
      } in
      Lambda(func_def)

and function_type (env : env) ((v1, v2, v3, v4) : CST.function_type) =
  let v1 =
    (match v1 with
     | Some (v1, v2) ->
         let v1 = simple_user_type env v1 in
         let v2 = token env v2 (* "." *) in
         todo env (v1, v2)
     | None -> todo env ())
  in
  let v2 = function_type_parameters env v2 in
  let v3 = token env v3 (* "->" *) in
  let v4 = type_ env v4 in
  todo env (v1, v2, v3, v4)

and function_type_parameters (env : env) ((v1, v2, v3) : CST.function_type_parameters) =
  let v1 = token env v1 (* "(" *) in
  let v2 =
    (match v2 with
     | Some (v1, v2) ->
         let v1 = anon_choice_param_b77c1d8 env v1 in
         let v2 =
           List.map (fun (v1, v2) ->
             let v1 = token env v1 (* "," *) in
             let v2 = anon_choice_param_b77c1d8 env v2 in
             todo env (v1, v2)
           ) v2
         in
         todo env (v1, v2)
     | None -> todo env ())
  in
  let v3 = token env v3 (* ")" *) in
  todo env (v1, v2, v3)

and function_value_parameter (env : env) ((v1, v2, v3) : CST.function_value_parameter) =
  let v1 =
    (match v1 with
     | Some x -> parameter_modifiers env x
     | None -> todo env ())
  in
  let v2 = parameter env v2 in
  let v3 =
    (match v3 with
     | Some (v1, v2) ->
         let v1 = token env v1 (* "=" *) in
         let v2 = expression env v2 in
         todo env (v1, v2)
     | None -> todo env ())
  in
  todo env (v1, v2, v3)

and function_value_parameters (env : env) ((v1, v2, v3) : CST.function_value_parameters) =
  let v1 = token env v1 (* "(" *) in
  let v2 =
    (match v2 with
     | Some (v1, v2) ->
         let v1 = function_value_parameter env v1 in
         let v2 =
           List.map (fun (v1, v2) ->
             let v1 = token env v1 (* "," *) in
             let v2 = function_value_parameter env v2 in
             todo env (v1, v2)
           ) v2
         in
         todo env (v1, v2)
     | None -> todo env ())
  in
  let v3 = token env v3 (* ")" *) in
  todo env (v1, v2, v3)

and getter (env : env) ((v1, v2) : CST.getter) =
  let v1 = token env v1 (* "get" *) in
  let v2 =
    (match v2 with
     | Some (v1, v2, v3, v4) ->
         let v1 = token env v1 (* "(" *) in
         let v2 = token env v2 (* ")" *) in
         let v3 =
           (match v3 with
            | Some (v1, v2) ->
                let v1 = token env v1 (* ":" *) in
                let v2 = type_ env v2 in
                todo env (v1, v2)
            | None -> todo env ())
         in
         let v4 = function_body env v4 in
         todo env (v1, v2, v3, v4)
     | None -> todo env ())
  in
  todo env (v1, v2)

and indexing_suffix (env : env) ((v1, v2, v3, v4) : CST.indexing_suffix) =
  let v1 = token env v1 (* "[" *) in
  let v2 = Arg (expression env v2) in
  let v3 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = Arg (expression env v2) in
      v2
    ) v3
  in
  let combine = v2::v3 in
  let v4 = token env v4 (* "]" *) in
  (v1, combine, v4)

and interpolation (env : env) (x : CST.interpolation) =
  (match x with
   | `DOLLARLCURL_exp_RCURL (v1, v2, v3) ->
       let v1 = token env v1 (* "${" *) in
       let v2 = expression env v2 in
       let v3 = token env v3 (* "}" *) in
       todo env (v1, v2, v3)
   | `DOLLAR_simple_id (v1, v2) ->
       let v1 = token env v1 (* "$" *) in
       let v2 = simple_identifier env v2 in
       todo env (v1, v2)
  )

and jump_expression (env : env) (x : CST.jump_expression) =
  match x with
  | `Throw_exp (v1, v2) ->
      let v1 = token env v1 (* "throw" *) in
      let v2 = expression env v2 in
      Throw (v1, v2, sc)
  | `Choice_ret_opt_exp (v1, v2) ->
      let v1 =
        (match v1 with
         | `Ret tok ->
             let v1 = token env tok (* "return" *) in
             (v1, None)
         | `Ret_at x -> return_at env x
        )
      in
      let v2 =
        (match v2 with
         | Some x ->
             let v1 = expression env x in
             Some v1
         | None -> None)
      in
      let return_tok, id = v1 in
      (match id with
       | None -> Return (return_tok, v2, sc)
       | Some simple_id ->
           let id = Id(simple_id, empty_id_info()) in
           (match v2 with
            | None ->
                let list = [TodoK ("todo return@", return_tok);E id] in
                OtherStmt (OS_Todo, list)
            | Some v2_expr ->
                let list = [TodoK ("todo return@", return_tok);E id; E v2_expr] in
                OtherStmt (OS_Todo, list)
           )
      )
  | `Cont tok ->
      let v1 = token env tok (* "continue" *) in
      Continue (v1, LNone, sc)
  | `Cont_at (v1, v2) ->
      let v1 = token env v1 (* "continue@" *) in
      let v2 = simple_identifier env v2 in
      let ident = LId (v2) in
      Continue (v1, ident, sc)
  | `Brk tok ->
      let v1 = token env tok (* "break" *) in
      Break (v1, LNone, sc)
  | `Brk_at (v1, v2) ->
      let v1 = token env v1 (* "break@" *) in
      let v2 = simple_identifier env v2 in
      let ident = LId (v2) in
      Break (v1, ident, sc)

and lambda_literal (env : env) ((v1, v2, v3, v4) : CST.lambda_literal) =
  let v1 = token env v1 (* "{" *) in
  let v2 =
    (match v2 with
     | Some (v1, v2) ->
         let v1 =
           (match v1 with
            | Some x -> lambda_parameters env x
            | None -> [])
         in
         let v2 = token env v2 (* "->" *) in
         v1
     | None -> [])
  in
  let v3 =
    (match v3 with
     | Some x -> statements env x
     | None -> [])
  in
  let block_v3 = Block (fake_bracket v3) in
  let v4 = token env v4 (* "}" *) in
  let kind = LambdaKind, v1 in
  let func_def = {
    fkind =  kind;
    fparams =  [];
    frettype =  None;
    fbody = block_v3;
  } in
  Lambda (func_def)

and lambda_parameter (env : env) (x : CST.lambda_parameter) =
  (match x with
   | `Var_decl x -> variable_declaration env x
  )

and lambda_parameters (env : env) ((v1, v2) : CST.lambda_parameters) =
  let v1 = lambda_parameter env v1 in
  let v2 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = lambda_parameter env v2 in
      v2
    ) v2
  in
  v1::v2

and loop_statement (env : env) (x : CST.loop_statement) =
  (match x with
   | `For_stmt (v1, v2, v3, v4, v5, v6, v7, v8) ->
       let v1 = token env v1 (* "for" *) in
       let v2 = token env v2 (* "(" *) in
       let v3 = List.map (annotation env) v3 in
       let v4 = lambda_parameter env v4 in
       let v5 = token env v5 (* "in" *) in
       let v6 = expression env v6 in
       let v7 = token env v7 (* ")" *) in
       let v8 =
         (match v8 with
          | Some x -> control_structure_body env x
          | None -> todo env ())
       in
       todo env (v1, v2, v3, v4, v5, v6, v7, v8)
   | `While_stmt (v1, v2, v3, v4, v5) ->
       let v1 = token env v1 (* "while" *) in
       let v2 = token env v2 (* "(" *) in
       let v3 = expression env v3 in
       let v4 = token env v4 (* ")" *) in
       let v5 =
         (match v5 with
          | `SEMI tok -> let _ = token env tok in  (* ";" *)
              raise Todo
          | `Cont_stru_body x -> control_structure_body env x
         )
       in
       todo env (v1, v2, v3, v4, v5)
   | `Do_while_stmt (v1, v2, v3, v4, v5, v6) ->
       let v1 = token env v1 (* "do" *) in
       let v2 =
         (match v2 with
          | Some x -> control_structure_body env x
          | None -> todo env ())
       in
       let v3 = token env v3 (* "while" *) in
       let v4 = token env v4 (* "(" *) in
       let v5 = expression env v5 in
       let v6 = token env v6 (* ")" *) in
       todo env (v1, v2, v3, v4, v5, v6)
  )

and modifiers (env : env) (x : CST.modifiers) =
  (match x with
   | `Anno x -> annotation env x
   | `Rep1_modi xs -> List.map (modifier env) xs
  )

and navigation_suffix (env : env) ((v1, v2) : CST.navigation_suffix) =
  let v1 = member_access_operator env v1 in
  let v2 =
    (match v2 with
     | `Simple_id x -> let id = simple_identifier env x in
         Id(id, empty_id_info())
     | `Paren_exp x -> parenthesized_expression env x
     | `Class tok -> let id = str env tok in (* "class" *)
         Id (id, empty_id_info())
    )
  in
  v2

and nullable_type (env : env) ((v1, v2) : CST.nullable_type) =
  let v1 =
    (match v1 with
     | `Type_ref x -> type_reference env x
     | `Paren_type x -> parenthesized_type env x
    )
  in
  let v2 = List.map (token env) (* "?" *) v2 in
  todo env (v1, v2)

and parameter (env : env) ((v1, v2, v3) : CST.parameter) : parameter =
  let v1 = simple_identifier env v1 in
  let v2 = token env v2 (* ":" *) in
  let v3 = type_ env v3 in
  todo env (v1, v2, v3)

and parameter_modifiers (env : env) (x : CST.parameter_modifiers) =
  (match x with
   | `Anno x -> annotation env x
   | `Rep1_param_modi xs ->
       List.map (parameter_modifier env) xs
  )

and parameter_with_optional_type (env : env) ((v1, v2, v3) : CST.parameter_with_optional_type) =
  let v1 =
    (match v1 with
     | Some x -> parameter_modifiers env x
     | None -> todo env ())
  in
  let v2 = simple_identifier env v2 in
  let v3 =
    (match v3 with
     | Some (v1, v2) ->
         let v1 = token env v1 (* ":" *) in
         let v2 = type_ env v2 in
         todo env (v1, v2)
     | None -> todo env ())
  in
  todo env (v1, v2, v3)

and parenthesized_expression (env : env) ((v1, v2, v3) : CST.parenthesized_expression) =
  let v1 = token env v1 (* "(" *) in
  let v2 = expression env v2 in
  let v3 = token env v3 (* ")" *) in
  v2

and parenthesized_type (env : env) ((v1, v2, v3) : CST.parenthesized_type) =
  let v1 = token env v1 (* "(" *) in
  let v2 = type_ env v2 in
  let v3 = token env v3 (* ")" *) in
  v2

and primary_constructor (env : env) ((v1, v2) : CST.primary_constructor) =
  let v1 =
    (match v1 with
     | Some (v1, v2) ->
         let v1 =
           (match v1 with
            | Some x -> modifiers env x
            | None -> todo env ())
         in
         let v2 = token env v2 (* "constructor" *) in
         todo env (v1, v2)
     | None -> todo env ())
  in
  let v2 = class_parameters env v2 in
  todo env (v1, v2)

and primary_expression (env : env) (x : CST.primary_expression) : expr =
  (match x with
   | `Paren_exp x -> parenthesized_expression env x
   | `Simple_id x ->
       let id = simple_identifier env x in
       Id(id, empty_id_info())
   | `Lit_cst x -> L (literal_constant env x)
   | `Str_lit x -> L (String (string_literal env x))
   | `Call_ref (v1, v2, v3) ->
       let v1 =
         (match v1 with
          | Some x ->
              let id = simple_identifier env x in
              Id(id, empty_id_info())
          | None ->
              let fake_id = ("None", fake "None") in
              Id(fake_id, empty_id_info()))
       in
       let v2 = token env v2 (* "::" *) in
       let v3 =
         (match v3 with
          | `Simple_id x -> simple_identifier env x
          | `Class tok -> str env tok (* "class" *)
         )
       in
       let ident_v3 = EId v3 in
       DotAccess (v1, v2, ident_v3)
   | `Func_lit x -> function_literal env x
   | `Obj_lit (v1, v2, v3) ->
       let v1 = token env v1 (* "object" *) in
       let v2 =
         (match v2 with
          | Some (v1, v2) ->
              let v1 = token env v1 (* ":" *) in
              let v2 = delegation_specifiers env v2 in
              v2
          | None -> [])
       in
       let v3 = class_body env v3 in
       AnonClass {
         ckind = (Class, v1);
         cextends = [];
         cimplements = [];
         cmixins = [];
         cbody = v3;
       }
   | `Coll_lit (v1, v2, v3, v4) ->
       let v1 = token env v1 (* "[" *) in
       let v2 = expression env v2 in
       let v3 =
         List.map (fun (v1, v2) ->
           let v1 = token env v1 (* "," *) in
           let v2 = expression env v2 in
           v2
         ) v3
       in
       let v4 = token env v4 (* "]" *) in
       let all_expr = v2::v3 in
       let container_list = (v1, all_expr, v4) in
       Container (List, container_list)
   | `This_exp tok ->
       let tok = token env tok in
       IdSpecial(This, tok) (* "this" *)
   | `Super_exp v1 ->
       let tok = token env v1 in
       IdSpecial(Super, tok)
   | `If_exp (v1, v2, v3, v4, v5) ->
       let v1 = token env v1 (* "if" *) in
       let v2 = token env v2 (* "(" *) in
       let v3 = expression env v3 in
       let v4 = token env v4 (* ")" *) in
       let v5 =
         (match v5 with
          | `Cont_stru_body x ->
              let v1 = control_structure_body env x in
              (v1, None)
          | `SEMI tok ->
              token_todo env tok (* ";" *)
          | `Opt_cont_stru_body_opt_SEMI_else_choice_cont_stru_body (v1, v2, v3, v4) ->
              let v1 =
                (match v1 with
                 | Some x -> control_structure_body env x
                 | None -> todo env ())
              in
              (*let v2 =
                (match v2 with
                 | Some tok -> token env tok (* ";" *)
                 | None -> todo env ())
                in*)
              let v3 = token env v3 (* "else" *) in
              let v4 =
                (match v4 with
                 | `Cont_stru_body x -> control_structure_body env x
                 | `SEMI tok -> token_todo env tok (* ";" *)
                )
              in
              (v1, Some v4)
         )
       in
       let (v6, v7) = v5 in
       let if_stmt = If (v1, v3, v6, v7) in
       OtherExpr (OE_StmtExpr, [S if_stmt])
   | `When_exp (v1, v2, v3, v4, v5) ->
       let v1 = token env v1 (* "when" *) in
       let v2 =
         (match v2 with
          | Some x -> when_subject env x
          | None -> None)
       in
       let v3 = token env v3 (* "{" *) in
       let v4 = List.map (when_entry env) v4 in
       let v5 = token env v5 (* "}" *) in
       let switch_stmt = Switch (v1, v2, v4) in
       OtherExpr (OE_StmtExpr, [S switch_stmt])
   | `Try_exp (v1, v2, v3) ->
       let v1 = token env v1 (* "try" *) in
       let v2 = block env v2 in
       let v3 =
         (match v3 with
          | `Rep1_catch_blk_opt_fina_blk (v1, v2) ->
              let v1 = List.map (catch_block env) v1 in
              let v2 =
                (match v2 with
                 | Some x -> Some (finally_block env x)
                 | None -> None)
              in
              (v1, v2)
          | `Fina_blk x ->
              let finally = finally_block env x in
              ([], Some (finally))
         )
       in
       let catch, finally = v3 in
       let try_stmt = Try (v1, v2, catch, finally) in
       OtherExpr (OE_StmtExpr, [S try_stmt])
   | `Jump_exp x ->
       let v1 = jump_expression env x in
       OtherExpr (OE_StmtExpr, [S v1])
  )

and property_delegate (env : env) ((v1, v2) : CST.property_delegate) =
  let v1 = token env v1 (* "by" *) in
  let v2 = expression env v2 in
  todo env (v1, v2)

and range_test (env : env) ((v1, v2) : CST.range_test) =
  let v1 = in_operator env v1 in
  let v2 = expression env v2 in
  todo env (v1, v2)

and setter (env : env) ((v1, v2) : CST.setter) =
  let v1 = token env v1 (* "set" *) in
  let v2 =
    (match v2 with
     | Some (v1, v2, v3, v4, v5) ->
         let v1 = token env v1 (* "(" *) in
         let v2 = parameter_with_optional_type env v2 in
         let v3 = token env v3 (* ")" *) in
         let v4 =
           (match v4 with
            | Some (v1, v2) ->
                let v1 = token env v1 (* ":" *) in
                let v2 = type_ env v2 in
                todo env (v1, v2)
            | None -> todo env ())
         in
         let v5 = function_body env v5 in
         todo env (v1, v2, v3, v4, v5)
     | None -> todo env ())
  in
  todo env (v1, v2)

and simple_user_type (env : env) ((v1, v2) : CST.simple_user_type) =
  let v1 = simple_identifier env v1 in
  let v2 =
    (match v2 with
     | Some x -> type_arguments env x
     | None -> todo env ())
  in
  todo env (v1, v2)

and statement (env : env) (x : CST.statement) : stmt =
  (match x with
   | `Decl x -> let dec = declaration env x in
       DefStmt dec
   | `Rep_choice_label_choice_assign (_v1, v2) ->
       (*let v1 =
         List.map (fun x ->
           (match x with
           | `Label tok -> let t = token env tok in (* label *)
               raise Todo
           | `Anno x -> annotation env x
           )
         ) v1
         in*)
       let v2 =
         (match v2 with
          | `Assign x -> assignment env x
          | `Loop_stmt x -> loop_statement env x
          | `Exp x -> let v1 = expression env x in
              ExprStmt (v1, sc)
         )
       in
       v2
  )

and statements (env : env) ((v1, v2, v3) : CST.statements) =
  let v1 = statement env v1 in
  let v2 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* pattern [\r\n]+ *) in
      let v2 = statement env v2 in
      (*todo env (v1, v2)*)
      v2
    ) v2
  in
  let v3 =
    (match v3 with
     | Some tok -> Some (token env tok) (* pattern [\r\n]+ *)
     | None -> None)
  in
  (*todo env (v1, v2, v3)*)
  v1::v2

and string_literal (env : env) (x : CST.string_literal) =
  match x with
  | `Line_str_lit (v1, v2, v3) ->
      let v1 = token env v1 (* "\dq" *) in
      let v2 =
        List.map (fun x ->
          (match x with
           | `Line_str_content x -> line_string_content env x
           | `Interp x -> interpolation env x
          )
        ) v2
      in
      let v3 = token env v3 (* "\dq" *) in
      let str = v2 |> List.map fst |> String.concat "" in
      let toks = (v2 |> List.map snd) @ [v3] in
      str, PI.combine_infos v1 toks
  | `Multi_line_str_lit (v1, v2, v3) ->
      let v1 = token env v1 (* "\"\"\dq" *) in
      let v2 =
        List.map (fun x ->
          (match x with
           | `Multi_line_str_content x ->
               multi_line_string_content env x
           | `Interp x -> let _ = interpolation env x in
               raise Todo
          )
        ) v2
      in
      let v3 = token env v3 (* "\"\"\dq" *) in
      todo env (v1, v2, v3)

and type_ (env : env) ((v1, v2) : CST.type_) : type_ =
  let v1 =
    (match v1 with
     | Some x -> type_modifiers env x
     | None -> [])
  in
  let v2 =
    (match v2 with
     | `Paren_type x -> parenthesized_type env x
     | `Null_type x -> nullable_type env x
     | `Type_ref x -> type_reference env x
     | `Func_type x -> function_type env x
    )
  in
  todo env (v1, v2)

and type_arguments (env : env) ((v1, v2, v3, v4) : CST.type_arguments) =
  let v1 = token env v1 (* "<" *) in
  let v2 = type_projection env v2 in
  let v3 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = type_projection env v2 in
      v2
    ) v3
  in
  let v4 = token env v4 (* ">" *) in
  v2::v3

and type_constraint (env : env) ((v1, v2, v3, v4) : CST.type_constraint) =
  let v1 = List.map (annotation env) v1 in
  let v2 = simple_identifier env v2 in
  let v3 = token env v3 (* ":" *) in
  let v4 = type_ env v4 in
  todo env (v1, v2, v3, v4)

and type_constraints (env : env) ((v1, v2, v3) : CST.type_constraints) =
  let v1 = token env v1 (* "where" *) in
  let v2 = type_constraint env v2 in
  let v3 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "," *) in
      let v2 = type_constraint env v2 in
      todo env (v1, v2)
    ) v3
  in
  todo env (v1, v2, v3)

and type_modifier (env : env) (x : CST.type_modifier) =
  (match x with
   | `Anno x -> annotation env x
   | `Susp tok -> let t = token env tok (* "suspend" *) in
       raise Todo
  )

and type_modifiers (env : env) (xs : CST.type_modifiers) =
  List.map (type_modifier env) xs

and type_parameter (env : env) ((v1, v2, v3) : CST.type_parameter) =
  let v1 =
    (match v1 with
     | Some x -> type_parameter_modifiers env x
     | None -> todo env ())
  in
  let v2 = simple_identifier env v2 in
  let v3 =
    (match v3 with
     | Some (v1, v2) ->
         let v1 = token env v1 (* ":" *) in
         let v2 = type_ env v2 in
         todo env (v1, v2)
     | None -> todo env ())
  in
  todo env (v1, v2, v3)

and type_parameter_modifier (env : env) (x : CST.type_parameter_modifier) =
  (match x with
   | `Reif_modi tok -> let t = token env tok in (* "reified" *)
       raise Todo
   | `Vari_modi x -> type_projection_modifier env x
   | `Anno x -> annotation env x
  )

and type_parameter_modifiers (env : env) (xs : CST.type_parameter_modifiers) =
  List.map (type_parameter_modifier env) xs

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

and type_projection (env : env) (x : CST.type_projection) =
  (match x with
   | `Opt_type_proj_modifs_type (v1, v2) ->
       let _v1 =
         (match v1 with
          | Some x -> type_projection_modifiers env x
          | None -> [])
       in
       let v2 = type_ env v2 in
       let fake_token = Parse_info.fake_info "type projection" in
       let list = [TodoK ("todo type projection", fake_token);T v2] in
       OtherType (OT_Todo, list)
   | `STAR tok ->
       let star = str env tok in
       OtherType (OT_Todo, [TodoK star]) (* "*" *)
  )

and type_reference (env : env) (x : CST.type_reference) =
  (match x with
   | `User_type x -> user_type env x
   | `Dyna tok -> TyBuiltin (str env tok) (* "dynamic" *)
  )

and type_test (env : env) ((v1, v2) : CST.type_test) =
  let v1 = is_operator env v1 in
  let v2 = expression env v2 in
  todo env (v1, v2)

and unary_expression (env : env) (x : CST.unary_expression) =
  (match x with
   | `Post_exp (v1, v2) ->
       let v1 = expression env v1 in
       let v2, v3 = postfix_unary_operator env v2 in
       (match v2 with
        | Left incr_decr ->
            Call (IdSpecial (IncrDecr (incr_decr, Postfix), v3), fb[Arg v1])
        | Right operator ->
            Call (IdSpecial (Op (operator), v3), fb[Arg v1])
       )
   | `Call_exp (v1, v2) ->
       let v1 = expression env v1 in
       let v2 = call_suffix env v2 in
       Call (v1, v2)
   | `Inde_exp (v1, v2) ->
       let v1 = expression env v1 in
       let v2 = indexing_suffix env v2 in
       Call (v1, v2)
   | `Navi_exp (v1, v2) ->
       let v1 = expression env v1 in
       let v2 = navigation_suffix env v2 in
       Call (v1, fb[Arg v2])
   | `Prefix_exp (v1, v2) ->
       let str, tok =
         (match v1 with
          | `Anno x -> let _ = annotation env x in
              raise Todo
          | `Label tok -> token_todo env tok (* label *)
          | `Prefix_un_op x -> prefix_unary_operator env x
         )
       in
       let v2 = expression env v2 in
       (match str with
        | Left incr_decr ->
            Call (IdSpecial (IncrDecr (incr_decr, Postfix), tok), fb[Arg v2])
        | Right operator ->
            Call (IdSpecial (Op (operator), tok), fb[Arg v2])
       )
   | `As_exp (v1, v2, v3) ->
       let v1 = expression env v1 in
       let v2 = as_operator env v2 in
       let v3 = type_ env v3 in
       Cast(v3, v1)
   | `Spread_exp (v1, v2) ->
       let v1 = token env v1 (* "*" *) in
       let v2 = expression env v2 in
       Call (IdSpecial (Spread, v1), fb[Arg v2])
  )

and unescaped_annotation (env : env) (x : CST.unescaped_annotation) =
  (match x with
   | `Cons_invo x -> constructor_invocation env x
   | `User_type x -> user_type env x
  )

and user_type (env : env) ((v1, v2) : CST.user_type) =
  let v1 = simple_user_type env v1 in
  let v2 =
    List.map (fun (v1, v2) ->
      let v1 = token env v1 (* "." *) in
      let v2 = simple_user_type env v2 in
      todo env (v1, v2)
    ) v2
  in
  todo env (v1, v2)

and value_argument (env : env) ((v1, v2, v3, v4) : CST.value_argument) =
  let v1 =
    (match v1 with
     | Some x -> annotation env x
     | None -> todo env ())
  in
  let v2 =
    (match v2 with
     | Some (v1, v2) ->
         let v1 = simple_identifier env v1 in
         let v2 = token env v2 (* "=" *) in
         todo env (v1, v2)
     | None -> todo env ())
  in
  let v3 =
    (match v3 with
     | Some tok -> token env tok (* "*" *)
     | None -> todo env ())
  in
  let v4 = expression env v4 in
  todo env (v1, v2, v3, v4)

and value_arguments (env : env) ((v1, v2, v3) : CST.value_arguments) =
  let v1 = token env v1 (* "(" *) in
  let v2 =
    (match v2 with
     | Some (v1, v2) ->
         let v1 = value_argument env v1 in
         let v2 =
           List.map (fun (v1, v2) ->
             let v1 = token env v1 (* "," *) in
             let v2 = value_argument env v2 in
             v2
           ) v2
         in
         v1::v2
     | None -> [])
  in
  let v3 = token env v3 (* ")" *) in
  (v1, v2, v3)

and variable_declaration (env : env) ((v1, v2) : CST.variable_declaration) =
  let v1 = simple_identifier env v1 in
  let v2 =
    (match v2 with
     | Some (v1, v2) ->
         let v1 = token env v1 (* ":" *) in
         let v2 = type_ env v2 in
         Some v2
     | None -> None)
  in
  (v1, v2)

and when_condition (env : env) ((v1, v2, v3) : CST.when_condition) =
  let v1 = expression env v1 in
  let v2 = range_test env v2 in
  let v3 = type_test env v3 in
  todo env (v1, v2, v3)

and when_entry (env : env) ((v1, v2, v3, v4) : CST.when_entry) =
  let v1 =
    (match v1 with
     | `When_cond_rep_COMMA_when_cond (v1, v2) ->
         let v1 = when_condition env v1 in
         let v2 =
           List.map (fun (v1, v2) ->
             let v1 = token env v1 (* "," *) in
             let v2 = when_condition env v2 in
             v2
           ) v2
         in
         todo env (v1, v2)
     | `Else tok -> token env tok (* "else" *)
    )
  in
  let v2 = token env v2 (* "->" *) in
  let v3 = control_structure_body env v3 in
  let v4 =
    (match v4 with
     | Some tok ->
         let v1 = token env tok (* pattern [\r\n]+ *) in
         Some v1
     | None -> None)
  in
  todo env (v1, v2, v3, v4)

and when_subject (env : env) ((v1, v2, v3, v4) : CST.when_subject) =
  let v1 = token env v1 (* "(" *) in
  (*let v2 =
    (match v2 with
     | Some (v1, v2, v3, v4) ->
         let v1 = List.map (annotation env) v1 in
         let v2 = token env v2 (* "val" *) in
         let v3 = variable_declaration env v3 in
         let v4 = token env v4 (* "=" *) in
         todo env (v1, v2, v3, v4)
     | None -> todo env ())
    in*)
  let v3 = expression env v3 in
  let v4 = token env v4 (* ")" *) in
  Some v3

let rec parenthesized_user_type (env : env) ((v1, v2, v3) : CST.parenthesized_user_type) =
  let v1 = token env v1 (* "(" *) in
  let v2 =
    (match v2 with
     | `User_type x -> user_type env x
     | `Paren_user_type x -> parenthesized_user_type env x
    )
  in
  let v3 = token env v3 (* ")" *) in
  todo env (v1, v2, v3)

let file_annotation (env : env) ((v1, v2, v3, v4) : CST.file_annotation) =
  let v1 = token env v1 (* "@" *) in
  let v2 = token env v2 (* "file" *) in
  let v3 = token env v3 (* ":" *) in
  let v4 =
    (match v4 with
     | `LBRACK_rep1_unes_anno_RBRACK (v1, v2, v3) ->
         let v1 = token env v1 (* "[" *) in
         let v2 = List.map (unescaped_annotation env) v2 in
         let v3 = token env v3 (* "]" *) in
         todo env (v1, v2, v3)
     | `Unes_anno x -> unescaped_annotation env x
    )
  in
  todo env (v1, v2, v3, v4)

let source_file (env : env) ((v1, v2, v3, v4, v5) : CST.source_file) : program =
  (*let v1 =
     (match v1 with
     | Some x -> shebang_line env x
     | None -> todo env ())
    in
    let v2 =
     (match v2 with
     | Some (v1, v2) ->
         let v1 = List.map (file_annotation env) v1 in
         let v2 = token env v2 (* pattern [\r\n]+ *) in
         todo env (v1, v2)
     | None -> todo env ())
    in
    let v3 =
     (match v3 with
     | Some x -> package_header env x
     | None -> todo env ())
    in
    let v4 = List.map (import_header env) v4 in*)
  let v5 =
    List.map (fun (v1, v2) ->
      let v1 = statement env v1 in
      let v2 = token env v2 (* pattern [\r\n]+ *) in
      v1
    ) v5
  in
  v5


(*****************************************************************************)
(* Entry point *)
(*****************************************************************************)
let parse file =
  H.wrap_parser
    (fun () ->
       Parallel.backtrace_when_exn := false;
       Parallel.invoke Tree_sitter_kotlin.Parse.file file ()
    )
    (fun cst ->
       let env = { H.file; conv = H.line_col_to_pos file; extra = () } in

       try
         source_file env cst
       with
         (Failure "not implemented") as exn ->
           let s = Printexc.get_backtrace () in
           pr2 "Some constructs are not handled yet";
           pr2 "CST was:";
           CST.dump_tree cst;
           pr2 "Original backtrace:";
           pr2 s;
           raise exn
    )
