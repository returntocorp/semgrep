open Common
open OUnit

(*****************************************************************************)
(* Sgrep Unit tests *)
(*****************************************************************************)

let unittest ~any_gen_of_string =
  "sgrep(generic) features" >:: (fun () ->

    (* spec: pattern string, code string, should_match boolean *)
    let triples = [
      (* right now any_gen_of_string use the Python sgrep_spatch_pattern
       * parser so the syntax below must be valid Python code  
       *)

      (* ------------ *)
      (* spacing *)  
      (* ------------ *)
   
      (* basic string-match of course *)
      "foo(1,2)", "foo(1,2)", true;
      "foo(1,3)", "foo(1,2)", false;

      (* matches even when space or newline differs *)
      "foo(1,2)", "foo(1,     2)", true;
      "foo(1,2)", "foo(1,     
                        2)", true;
      (* matches even when have comments in the middle *)
      "foo(1,2)", "foo(1, #foo
                       2)", true;

      (* ------------ *)
      (* metavariables *)
      (* ------------ *)

      (* for identifiers *)
      "import $X", "import Foo", true;
      "x.$X", "x.foo", true;

      (* for expressions *)
      "foo($X)",  "foo(1)", true;
      "foo($X)",  "foo(1+1)", true;

      (* for lvalues *)
      "$X.method()",  "foo.method()", true;
      "$X.method()",  "foo.bar.method()", true;

      (* "linear" patterns, a la Prolog *)
      "$X & $X", "(a | b) & (a | b)", true;
      "foo($X, $X)", "foo(a, a)", true;
      "foo($X, $X)", "foo(a, b)", false;

      (* metavariable on function name *)
      "$X(1,2)", "foo(1,2)", true;
      (* metavariable on method call *)
      "$X.foo()", "Bar.foo()", true;
      (* should not match infix expressions though, even if those
       * are transformed internally in Calls *)
      "$X(...)", "a+b", false;

      (* metavariable for statements *)
      "if(True): $S
",
       "if(True): return 1
", true;

      (* metavariable for entity definitions *)
       "def $X():  return 1
",
       "def foo(): return 1
", true;

      (* metavariable for parameter *)
       "def foo($A, b):  return 1
",
       "def foo(x, b): return 1
", true;


      (* metavariable string for identifiers *)
(*     "foo('X');", "foo('a_func');", true; *)
      (* many arguments metavariables *)
(*      "foo($MANYARGS);", "foo(1,2,3);", true; *)

      (* ------------ *)
      (* '...' *)
      (* ------------ *)

      (* '...' in funcall *)
      "foo(...)", "foo()", true;
      "foo(...)", "foo(1)", true;
      "foo(...)", "foo(1,2)", true;
      "foo($X,...)", "foo(1,2)", true;

      (* ... also match when there is no additional arguments *)
      "foo($X,...)", "foo(1)", true;
      "foo(..., 3, ...)", "foo(1,2,3,4)", true;

      (* ... in more complex expressions *)
      "strstr(...) == False", "strstr(x)==False", true;

      (* in strings *)
      "foo(\"...\")", "foo(\"this is a long string\")", true;
     (* "foo(\"...\");", "foo(\"a string\" . \"another string\");", true;*)

      (* for stmts *)
      "if True: foo(); ...; bar()
",
      "if True: foo(); foobar(); bar()
", true;

     (* for parameters *)
       "def foo(...): ...
",
       "def foo(a, b): return a+b
", true;

       "def foo(..., foo=..., ...): ...
",
       "def foo(a, b, foo = 1, bar = 2): return a+b
", true;

(*      "class Foo { ... }", "class Foo { int x; }", true; *)
      (* '...' in arrays *)
(*      "foo($X, array(...));",  "foo(1, array(2, 3));", true; *)

      (* ------------ *)
      (* Misc isomorphisms *)
      (* ------------ *)
      (* flexible keyword argument matching, the order does not matter *)
      "foo(kwd1=$X, kwd2=$Y)", "foo(kwd2=1, kwd1=3)", true;

      (* regexp matching in strings *)
      "foo(\"=~/a+/\")", "foo(\"aaaa\")", true;
      "foo(\"=~/a+/\")", "foo(\"bbbb\")", false;
(*      "new Foo(...);","new Foo;", true; *)

    ]
    in
    triples |> List.iter (fun (spattern, scode, should_match) ->
     try 
      let pattern = any_gen_of_string spattern in
      let code    = any_gen_of_string scode in
      let matches_with_env = Semgrep_generic.match_any_any pattern code in
      if should_match
      then
        assert_bool (spf "pattern:|%s| should match |%s" spattern scode)
          (matches_with_env <> [])
      else
        assert_bool (spf "pattern:|%s| should not match |%s" spattern scode)
          (matches_with_env = [])
     with
      Parsing.Parse_error -> 
              failwith (spf "problem parsing %s or %s" spattern scode)
    )
  )
