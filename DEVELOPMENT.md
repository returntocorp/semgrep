# sgrep

[![CircleCI](https://circleci.com/gh/returntocorp/sgrep.svg?style=svg)](https://circleci.com/gh/returntocorp/sgrep)

`sgrep`, for syntactical (and occasionnally semantic) grep, is a
tool to help find bugs by specifying code patterns using a familiar
syntax. The idea is to mix the convenience of grep with the
correctness and precision of a compiler frontend.

Its main features are:
1. **Use concrete code syntax**: easy to learn
2. **Metavariables ($X)**: abstract away code
3. **'...' operator**: abstract away sequences
4. **Knows about code equivalences**: one pattern can match variations on the code
<!-- known previously as isomorphisms -->
5. **Less is more**: abstract away additional details
<!-- known previously as iso by absence -->

`sgrep` has good support for Python and JavaScript, with some support
for Java and C, and more languages on the way!

For more information see https://r2c.dev/sgrep-public.pdf

For more information on the use of sgrep in a linter-type workflow, see 
https://github.com/returntocorp/bento/blob/master/SGREP-README.md

## Installation from source

To compile sgrep, you first need to install OCaml and its
package manager OPAM. See https://opam.ocaml.org/doc/Install.html
On macOS, it should simply consist in doing:

```
brew install opam
opam init
opam switch create 4.07.1
opam switch 4.07.1
eval $(opam env)
```

Once OPAM is installed, you need to install the library pfff, 
the OCaml frontend reason, and the build system dune:

```
opam install pfff
opam install reason
opam install dune
```

sgrep probably needs the very latest features of pfff, which may not
be yet in the latest OPAM version of pfff. In that case, install pfff
manually by doing:

```
git clone https://github.com/returntocorp/pfff
cd pfff
./configure; make depend; make; make opt; make reinstall-libs
```

Then you can compile the program with:

```
dune build
```

You can also use the Dockerfile in this directory to build sgrep
inside a container.

## Run 

Then to test sgrep on a file, for example tests/GENERIC/test.py
run:

```
./_build/default/bin/main_sgrep.exe -e foo tests/python
...
```

If you want to test sgrep on a directory with a set of given rules, run:

```
cp ./_build/default/bin/main_sgrep.exe /usr/local/bin/sgrep
cp ./sgrep.py /usr/local/bin/sgrep-lint
sgrep-lint <YAML_FILE_OR_DIRECTORY> <code to check>
```

## Development Environment

You can use Visual Studio Code (vscode) to edit the code of sgrep. 
The reason-vscode Marketplace extension adds support for OCaml/Reason
(see https://marketplace.visualstudio.com/items?itemName=jaredly.reason-vscode).
The OCaml and Reason IDE extension by David Morrison is another valid 
extension, but it seems not as actively maintained as reason-vscode.

The source of sgrep contains also a .vscode/ directory at its root
containing a task file to automatically build sgrep from vscode.

Note that dune and ocamlmerlin must be in your PATH for vscode to correctly
build and provide cross-reference on the code. In case of problems, do:
n
```
cd /path/to/sgrep
eval $(opam env)
dune        --version # just checking dune is in your PATH
ocamlmerlin -version  # just checking ocamlmerlin is in your PATH
code .
```

## Debugging code

Set the OCAMLRUNPARAM environment variable to 'b' for backtrace. 
You will get better backtrace information when an exception is thrown.

```
export OCAMLRUNPARAM=b
```
