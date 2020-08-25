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

module PI = Parse_info

(* less: could infer lang from filename *)
let dump_tree_sitter_cst_lang lang file =
   match lang with
   | Lang.Ruby ->
      Tree_sitter_ruby.Parse.file file
      |> Tree_sitter_ruby.CST.dump_tree
   | Lang.Java ->
      Tree_sitter_java.Parse.file file
      |> Tree_sitter_java.CST.dump_tree
   | Lang.Go   ->
      Tree_sitter_go.Parse.file file
      |> Tree_sitter_go.CST.dump_tree
   | Lang.Csharp ->
      Tree_sitter_csharp.Parse.file file
      |> Tree_sitter_csharp.CST.dump_tree
   | Lang.Javascript ->
      Tree_sitter_javascript.Parse.file file
      |> Tree_sitter_javascript.CST.dump_tree

   | _ -> failwith "lang not supported by ocaml-tree-sitter"

let dump_tree_sitter_cst file =
  match Lang.langs_of_filename file with
  | [l] -> dump_tree_sitter_cst_lang l file
  | [] -> failwith (spf "no language detected for %s" file)
  | _::_::_ -> failwith (spf "too many languages detected for %s" file)

(* mostly a copy paste of Test_parsing_ruby.test_parse in pfff but using
 * the tree-sitter Ruby parser instead.
 *)
let test_parse_lang verbose lang get_final_files xs =
  let xs = List.map Common.fullpath xs in
  let fullxs = get_final_files xs
      |> Skip_code.filter_files_if_skip_list ~root:xs
    in
  let lang =
    match Lang.lang_of_string_opt lang with
    | Some l -> l
    | None -> failwith "no language specified; use -lang"
  in

  let stat_list = ref [] in
  fullxs |> Console.progress (fun k -> List.iter (fun file ->
    k();
    if verbose then pr2 (spf "processing %s" file);
    let stat =
    (try
       if true
       then begin
          (* use tree-sitter parser and converters *)
          Parse_code.parse_and_resolve_name_use_pfff_or_treesitter lang file
          |> ignore
       end else begin
          (* just the tree-sitter CST parsing  *)
          (* Execute in its own process, so GC bugs will not pop-out here.
           * Slower, but safer for now, otherwise get segfaults probably
           * because of bugs in tree-sitter OCaml bindings.
           *)
           Parallel.backtrace_when_exn := true;
           Parallel.invoke
             (fun file -> dump_tree_sitter_cst_lang lang file)
             file ()
        end;
       PI.correct_stat file
    with exn ->
        pr2 (spf "%s: exn = %s" file (Common.exn_to_s exn));
        PI.bad_stat file
    )
    in
    Common.push stat stat_list;
  ));
  flush stdout; flush stderr;

  Parse_info.print_parsing_stat_list !stat_list;
  ()
