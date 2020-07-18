#!/bin/bash
set -e
brew install opam pkg-config coreutils
opam init --no-setup --bare;
opam switch create 4.10.0;
opam switch 4.10.0;
git submodule update --init --recursive

eval "$(opam env)"

make setup
make config

# Remove dynamically linked libraries to force MacOS to use static ones
rm /usr/local/lib/libtree-sitter.0.0.dylib
rm /usr/local/lib/libtree-sitter.dylib

make build-core

mkdir -p artifacts
if [[ -z "$SKIP_NUITKA" ]]; then
  (
    cd semgrep
    sudo make all
  )
  cp -r ./semgrep/build/semgrep.dist/* artifacts/
fi
cp ./semgrep-core/_build/default/bin/Main.exe artifacts/semgrep-core
zip -r artifacts.zip artifacts
