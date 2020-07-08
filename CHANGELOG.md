# Changelog

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Default Docker code mount point from `/home/repo` to `/src` - this is also
  configurable via the `SEMGREP_SRC_DIRECTORY` environment variable

### Removed
- `--precommit` flag - this is no longer necessary after defaulting to
  `pre-commit`'s code mount point `/src`

### Fixed
- Parse python files with trailing whitespace
- Parse python2 tuple as parameter in function/lambda definition
- Parse python3.8 positional only parameters (PEP 570)
- Parse python2 implicit array in comprehension

## [0.13.0](https://github.com/returntocorp/semgrep/releases/tag/v0.13.0) - 2020-06-30

### Added
- Const propagation now works with Java 'final' keyword and for Python globals
  which were assigned only once in the program

### Fixed
- Parsing Ocaml open overriding
- Parse raise in Python2 can take up to three arguments
- Metavariable matching now works with variables with global scope:
```yaml
$CONST = "..."
...
def $FUNC(...):
  return foo($CONST)
```
will match
```python
GLOBAL_CONST = "SOME_CONST"

def fetch_global_const():
    return foo(GLOBAL_CONST)
```

### Changed
- More clear Parse error message

## [0.12.0](https://github.com/returntocorp/semgrep/releases/tag/v0.12.0) - 2020-06-23

### Added
- Support for a new configuration language: JSON. You can now write
  JSON semgrep patterns with -lang json
- Support for '...' inside set and dictionaries
- Version check to recommend updating when out-of-date, disable with `--disable-version-check`
- Support for multiline pattern-where-python
- `--dryrun` flag to show result of autofixes without modifying any files
- Add capability to use regex replacement for autofixing. See documentaion [here](https://github.com/returntocorp/semgrep/blob/develop/docs/experimental.md#autofix-using-regular-expression-replacement)
- Add version check to recommend upgrading when applicable

### Fixed
- The range of function calls and statement blocks now includes the closing
  `}` and `)`. The range for expression statements now includes the closing
  ';' when there's one. The range of decorators now includes '@'.
- Do not convert certain parenthesized expressions in tuples in Python
- Returned warning when improperly mounting volume in docker container
- Correctly handle uncommited file deletions when using git aware file targeting

### Changed
- Progress bar only displays when in interactive terminal, more than one
  rule is being run, and not being run with `-v` or `-q`
- Colapsed `--include-dir` and `--exclude-dir` functionaity into `--include` and
  `--exclude` respectively

## [0.11.0](https://github.com/returntocorp/semgrep/releases/tag/v0.11.0) - 2020-06-16

### Added
- Support for another programming language: OCaml. You can now write
  OCaml semgrep patterns with -lang ocaml
- Inline whitelisting capabilities via `nosem` comments and the
  `--disable-nosem` flag [#900](https://github.com/returntocorp/semgrep/issues/900)
- Show a progress bar when using semgrep in an interactive shell
- More understandable error messages

### Changed
- If scanning a directory in a git project then skip files that are ignored by the
  project unless `--no-git-ignore` flag is used
- Show aggregate parse errors unless `--verbose` flag is used

### Fixed
- Handle parsing unicode characters

## [0.10.1](https://github.com/returntocorp/semgrep/releases/tag/v0.10.1) - 2020-06-10

### Fixed
- Value of `pattern_id` when using nested pattern operators [#828](https://github.com/returntocorp/semgrep/issues/828)
- `...` now works inside for loops in javascript
- Metavariable
- Infinite loop in python [#923](https://github.com/returntocorp/semgrep/issues/923)
- Treat field definition (`{x: 1}`) differently from assignment (`{x = 1}`)
- Support triple-quoted f-strings in python
- Fix ubuntu build error [#965](https://github.com/returntocorp/semgrep/pull/965)

## [0.10.0](https://github.com/returntocorp/semgrep/releases/tag/v0.10.0) - 2020-06-09

### Fixed

- Support immediately indexed arrays with initializers in Java
- Support object rest parameters in ECMAScript 6+
- Support various array destructuring calls with ommitted arguments in
  ECMAScript 6+
- Fix an issue where an error was raised when matching to Python else
  blocks with a metavariable
- Don't filter out files that are explicitly passed as arguments to semgrep
  even if they do not have expected extension

### Added

- Java imports can now be searched with patterns written like `import
  javax.crypto.$ANYTHING`
- `--debugging-json` flag for use on semgrep.live

### Changed

- Pattern matches now distinguish between conditionals without `else` blocks
  and those with empty `else` blocks; write two patterns to capture both
  possibilities
- Print output before exiting when using --strict

## [0.9.0](https://github.com/returntocorp/semgrep/releases/tag/v0.9.0) - 2020-06-02

### Fixed
- Performance optimizations in deep statement matching
- Disable normalization of != ==> !(==)
- Support empty variable declaration in javasript
- Support "print expr," in Python 2.X
- Support "async" keyword on inner arrow functions for ECMAScript 7+
- Support optional catch bindings for ECMAScript 2019+
- Support non-ASCII Unicode whitespace code points as lexical whitespace in JavaScript code
- Support assignment expressions in Python 3.8
- Emtpty block in if will only match empty blocks

### Removed
- `--exclude-tests` flag - prefer `--exclude` or `--exclude-dir`
- `--r2c` flag - this was completely unused

## [0.8.1](https://github.com/returntocorp/semgrep/releases/tag/v0.8.1) - 2020-05-26

### Fixed
- `semgrep --version` on ubuntu was not returning the correct version

## [0.8.0](https://github.com/returntocorp/semgrep/releases/tag/v0.8.0) - 2020-05-20

### Added
- `pattern-regex` functionality - see docs for more information.
- Ellipsis used in the final position of a sequence of binary operations
  will match any number of additional arguments:
  ```
  $X = 1 + 2 + ...
  ```
  will match
  ```python
  foo = 1 + 2 + 3 + 4
  ```
- Per rule configuration of paths to include/exclude. See docs for more information.

### Changed
- fstring pattern will only match fstrings in Python:
  ```
  f"..."
  ```
  will match
  ```python
  f"foo {1 + 1}"
  ```
  but not
  ```python
  "foo"
  ```
- Change location of r2c rule config to https://semgrep.live/c/r/all which filters out
  pattern-where-python rules

## [0.7.0](https://github.com/returntocorp/semgrep/releases/tag/v0.7.0) - 2020-05-12

### Added
- `--exclude`, `--include`, `--exclude-dir`, and `--include-dir` flags
  for targeting specific paths with command line options.
  The behavior of these flags mimics `grep`'s behavior.
- A `--sarif` flag to receive output formatted according to the
  [SARIF v2.1.0](https://docs.oasis-open.org/sarif/sarif/v2.1.0/cs01/sarif-v2.1.0-cs01.html)
  specification for static analysis tools.
- Metavariables are now checked for equality across pattern clauses. For example, in the following pattern, `$REQ` must be the same variable name for this to match:
  ```yaml
  - patterns:
    - pattern-inside: |
        $TYPE $METHOD(..., HttpServletRequest $REQ, ...) {
          ...
        }
    - pattern: $REQ.getQueryString(...);
  ```


### Fixed
- Correclty parse implicit tuples in python f-strings
- Correctly parse `%` token in python f-string format
- Correctly parse python fstrings with spaces in interpolants

## [0.6.1](https://github.com/returntocorp/semgrep/releases/tag/v0.6.1) - 2020-05-06

### Fix

- Message field in output was not using proper interpolated message

## [0.6.0](https://github.com/returntocorp/semgrep/releases/tag/v0.6.0) - 2020-05-05

### Added
- The `-j/--jobs` flag for specifying number of subprocesses to use to run checks in parallel.
- expression statements will now match by default also return statements
  ```
  foo();
  ```
  will now match
  ```javascript
  return foo();
  ```
- You can now use regexps for field names:
  ```
  var $X = {"=~/[lL]ocation/": $Y};
  ```
  will now match
  ```javascript
  var x = {"Location": 1};
  ```
- Add severity to json output and prepend the rule line with it. Color yellow if `WARNING`, and red if `ERROR`. e.g. WARNING rule:tests.equivalence-tests
- For languages not allowing the dollar sign in identifiers (e.g., Python),
  semgrep will return an error if your pattern contains an identifier
  starting with a dollar that is actually not considered a metavariable
  (e.g., `$x`)
- Support top level `metadata` field in rule.yaml. Entire metadata object is attached to
  all things that match the rule when using json output format.

### Changed
- Config files in hidden paths can now be used by explicitly specifying
  the hidden path:
    ```
    semgrep --config some/hidden/.directory
    ```
- Metavariables can now contain digits or `_`. `$USERS_2` is now
  a valid metavariable name. A metavariable must start with a letter
  or `_` though.
- Simple calls of the `semgrep` CLI, such as `semgrep --version`, are now 60% faster.
- Display autofix suggestion in regular and json output mode.
- Update command line help texts.

### Fixed
- Correctly parse `f"{foo:,f}"` in Python
- Correctly parse Python files where the last line is a comment

## [0.5.0](https://github.com/returntocorp/semgrep/releases/tag/v0.5.0) - 2020-04-28

### Changed
- Rename executable to semgrep
- Deep expression matching in conditionals requires different syntax:
    ```
    if <... $X = True ...>:
        ...
    ```
    will now match
    ```python
    if foo == bar and baz == True:
        return 1
    ```
- Deduplicate semgrep output in cases where there are multiple ways
  a rule matches section of code
- Deep statement matchings goes into functions and classes:
    ```
    $X = ...
    ...
    bar($X)
    ```
    now matches with
    ```javascript
    QUX = "qux"

    function baz() {
        function foo() {
            bar(QUX)
        }
    }
    ```

### Added
- `python2` is a valid supported language

### Fixed
- Expression will right hand side of assignment/variable definition in javascript. See #429
    ```
    foo();
    ```
    will now match
    ```
    var x = foo();
    ```
- Regression where `"..."` was matching empty list
    ```
    foo("...")
    ```
    does _not_ match
    ```
    foo()
    ```

## [0.4.9](https://github.com/returntocorp/semgrep/releases/tag/v0.4.9) - 2020-04-07

### Changed

- Only print out number of configs and rules when running with verbose flag
- Match let and const to var in javascript:
    ```
    var $F = "hello"
    ```
    will now match any of the following expressions:
    ```javascript
    var foo = "hello";
    let bar = "hello";
    const baz = "hello";
    ```

### Added

- Print out --dump-ast
- Print out version with `--version`
- Allow ... in arrays
    ```
    [..., 1]
    ```
    will now match
    ```
    [3, 2, 1]
    ```
- Support Metavariable match on keyword arguments in python:
    ```
    foo(..., $K=$B, ...)
    ```
    will now match
    ```
    foo(1, 2, bar=baz, 3)
    ```
- Support constant propogation in f-strings in python:
    ```
    $M = "..."
    ...
    $Q = f"...{$M}..."
    ```
    will now match
    ```python
    foo = "bar"
    baz = f"qux {foo}"
    ```
- Constant propogation in javascript:
    ```
    api("literal");
    ```
    will now match with any of the following:
    ```javascript
    api("literal");

    const LITERAL = "literal";
    api(LITERAL);

    const LIT = "lit";
    api(LIT + "eral");

    const LIT = "lit";
    api(`${LIT}eral`);
    ```

- Deep statement matching:
    Elipsis operator (`...`) will also include going deeper in scope (i.e. if-else, try-catch, loop, etc.)
    ```
    foo()
    ...
    bar()
    ```
    will now match
    ```python
    foo()
    if baz():
        try:
            bar()
        except Exception:
            pass
    ```
- Unified import resolution in python:
    ```
    import foo.bar.baz
    ```

    will now match any of the following statements:

    ```python
    import foo.bar.baz
    import foo.bar.baz.qux
    import foo.bar.baz as flob
    import foo.bar.baz.qux as flob
    from foo.bar import baz
    from foo.bar.baz import qux
    from foo.bar import baz as flob
    from foo.bar.bax import qux as flob
    ```
- Support for anonymous functions in javascript:
    ```
    function() {
        ...
    }
    ```
    will now match
    ```javascript
    var bar = foo(
        //matches the following line
        function () { console.log("baz"); }
    );
    ```
- Support arrow function in javascript
    ```
    (a) => { ... }
    ```
    will now match:

    ```javascript
    foo( (a) => { console.log("foo"); });
    foo( a => console.log("foo"));

    // arrows are normalized in regular Lambda, so an arrow pattern
    // will match also old-style anynonous function.
    foo(function (a) { console.log("foo"); });
    ```
- Python implicit string concatenation
    ```
    $X = "..."
    ```
    will now match
    ```python
    # python implicitly concatenates strings
    foo = "bar"       "baz"              "qux"
    ```
- Resolve alias in attributes and decorators in python
    ```
    @foo.bar.baz
    def $X(...):
        ...
    ```
    will now match
    ```python
    from foo.bar import baz

    @baz
    def qux():
        print("hello")
    ```
### Fixed

- Handle misordered multiple object destructuring assignments in javascript:
    ```
    var {foo, bar} = qux;
    ```
    will now match
    ```
    var {bar, baz, foo} = qux;
    ```
- Defining properties/functions in different order:
    ```
    var $F = {
        two: 2,
        one: 1
    };
    ```
    will now match both
    ```javascript
    var foo = {
      two: 2,
      one: 1
    };

    var bar = {
        one: 1,
        two: 2
    };
    ```
- Metavariables were not matching due to go parser adding empty statements in golang


## [0.4.8](https://github.com/returntocorp/semgrep/releases/tag/0.4.8) - 2020-03-09

### Added
* Constant propagation for some langauges. Golang example:
```
pattern: dangerous1("...")
will match:

const Bar = "password"
func foo() {
     dangerous1(Bar);
}
```

* Import matching equivalences
```
pattern: import foo.bar.a2
matches code: from foo.bar import a1, a2
```

* Deep expression matching - see (#264)
```
pattern: bar();
matches code: print(bar())
```
