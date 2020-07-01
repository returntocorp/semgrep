(*s: semgrep/matching/Unit_matcher.ml *)
open Common
open OUnit

module A = AST_generic
module PPG = Pretty_print_generic

(*****************************************************************************)
(* Semgrep Unit tests *)
(*****************************************************************************)
let test_path = "../../../tests/SYNTHESIZING/"

let python_tests = [
  "arrays_and_funcs.py", "3:3-3:23",
  ["exact match", "a.bar(f(x), y == f(x))";
   "dots", "a.bar(...)";
   "metavars", "a.bar($X, $Y, ...)";
   "exact metavars", "a.bar($X, $Y)";
   "deep metavars", "a.bar(f($X), $Y == f($X))"
  ];

  "arrays_and_funcs.py", "4:9-4:29",
  ["exact match", "metrics.send('my-report-id')";
   "dots", "metrics.send(...)";
   "metavars", "metrics.send($X, ...)";
   "exact metavars", "metrics.send($X)"
  ];

  "arrays_and_funcs.py", "5:4-5:11",
  ["exact match", "(hi, my)"];

  "arrays_and_funcs.py", "6:1-6:14",
  ["exact match", "(hi, my, bye)"];

  "arrays_and_funcs.py", "7:3-7:7",
  ["exact match", "A[1]"];

  "arrays_and_funcs.py", "8:3-8:8",
  ["exact match", "A[-(1)]"];

  "arrays_and_funcs.py", "9:3-9:9",
  ["exact match", "A[1:4]"];

  "arrays_and_funcs.py", "10:3-10:12",
  ["exact match", "A[1:4:-(1)]"];

  "arrays_and_funcs.py", "11:3-11:10",
  ["exact match", "A[::-(1)]"];

  "arrays_and_funcs.py", "12:3-12:8",
  ["exact match", "A[1:]"];

  "arrays_and_funcs.py", "13:3-13:14",
  ["exact match", "1 == 1";
   "exact metavars", "$X == $X"];

  "arrays_and_funcs.py", "14:3-14:7",
  ["exact match", "true";
   "metavar", "$X"];

  "arrays_and_funcs.py", "15:3-15:6",
  ["exact match", "3.3";
   "metavar", "$X"];

  "arrays_and_funcs.py", "16:3-16:12",
  ["exact match", "self.data";
   "metavar", "$X"];

  "arrays_and_funcs.py", "17:3-17:36",
  ["exact match", "'nice' if is_nice else 'not nice'"];

  "arrays_and_funcs.py", "18:3-18:34",
  ["exact match", "f(a, b(g(a, k)), c, c(k), a, c)";
   "dots", "f(...)";
   "metavars", "f($X, $Y, $Z, $A, $X, $Z, ...)";
   "exact metavars", "f($X, $Y, $Z, $A, $X, $Z)";
   "deep metavars", "f($X, b(g($X, $Y)), $Z, c($Y), $X, $Z)"
  ];

  "arrays_and_funcs.py", "19:3-19:32",
  ["exact match", "node.id == node.id";
   "exact metavars", "$X == $X"];
]

let unittest ~any_gen_of_string =
  "pattern inference features" >:: (fun () ->
    let cases = [Lang.Python, python_tests]
    in
    cases |> List.iter (fun (lang, tests) ->
    tests |> List.iter (fun (filename, range, sols) ->
        let file = test_path ^ filename in
        let pats = Synthesizer.synthesize_patterns range file in
        let code = Parse_generic.parse_program file in
        let r = Range.range_of_linecol_spec range file in
        Naming_AST.resolve lang code;
        let check_pats (_, pat) =
          try
            let pattern = any_gen_of_string pat in
            let e_opt = Range_to_AST.expr_at_range r code in
               match e_opt with
                 | Some e ->
                    let matches_with_env = Semgrep_generic.match_any_any pattern (A.E e) in
                    assert_bool (spf "pattern:|%s| should match |%s" pat (PPG.pattern_to_string lang (A.E e)))
                    (matches_with_env <> [])
                 | None -> failwith (spf "Couldn't find range %s in %s" range file)
          with
            Parsing.Parse_error ->
            failwith (spf "problem parsing %s" pat)
        in
        pats |> List.iter check_pats;
        assert(pats = sols)
    )
    )
  )
