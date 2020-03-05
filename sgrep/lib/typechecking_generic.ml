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
open Ast_generic

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* Poor's man typechecker on literals (for now).
 *
 * todo: 
 *  - local type inference on AST generic? good coverage?
 *  - we could allow metavars on the type itself, as in
 *    foo($X: $T) ... $T x; ...
 *    which would require to transform the code in the generic_vs_generic
 *    style as typechecking could also bind metavariables in the process
 *)

(*****************************************************************************)
(* Entry point *)
(*****************************************************************************)

(* very Python specific for now where the type is currently an OT_Expr
 * TODO: fill Ast_generic.expr_to_type at least.
 *)
let compatible_type t e =
  match t, e with
  | OtherType (OT_Expr, [E (Id (("int", _tok), _idinfo))]),
    L (Int _) -> true
  | OtherType (OT_Expr, [E (Id (("float", _tok), _idinfo))]),
    L (Float _) -> true
  | OtherType (OT_Expr, [E (Id (("str", _tok), _idinfo))]),
    L (String _) -> true

  | _ -> false
