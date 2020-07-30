#
# This makefile is targeted at developers.
# For a one-shot production build, look into Dockerfile.
#

# Routine build. It assumes all dependencies and configuration are already
# in place and correct. It should be fast since it's called often during
# development.
#
.PHONY: build
build:
	$(MAKE) build-core
	cd semgrep && python3 -m pipenv install --dev

.PHONY: build-core
build-core: build-pfff build-ocaml-tree-sitter
	$(MAKE) -C semgrep-core

.PHONY: build-pfff
build-pfff:
	$(MAKE) -C pfff
	$(MAKE) -C pfff opt
	$(MAKE) -C pfff reinstall-libs

.PHONY: build-ocaml-tree-sitter
build-ocaml-tree-sitter:
	$(MAKE) -C ocaml-tree-sitter
	$(MAKE) -C ocaml-tree-sitter install

# Update and rebuild everything within the project.
#
# At the moment, this is useful when pfff or ocaml-tree-sitter get updated,
# since semgrep-core is not rebuilt automatically when they change.
#
.PHONY: rebuild
rebuild:
	git submodule update --init --recursive
	$(MAKE) clean
	$(MAKE) config
	$(MAKE) build

# This is a best effort to install some external dependencies.
# Should run infrequently.
#
.PHONY: setup
setup:
	git submodule update --init --recursive
	opam update -y
	opam install -y --deps-only ./pfff
	cd ocaml-tree-sitter && ./scripts/install-tree-sitter-lib
	opam install -y --deps-only ./ocaml-tree-sitter
	opam install -y --deps-only ./semgrep-core

# This needs to run initially or when something changed in the external
# build environment. This typically looks for the location of libraries
# and header files outside of the project.
#
.PHONY: config
config:
	cd pfff && ./configure && $(MAKE) depend
	cd ocaml-tree-sitter && ./configure

# Remove from the project tree everything that's not under source control
# and was not created by 'make setup'.
#
.PHONY: clean
clean:
	$(MAKE) -C pfff clean
	$(MAKE) -C ocaml-tree-sitter clean
	$(MAKE) -C semgrep-core clean
	$(MAKE) -C semgrep clean

# Same as 'make clean' but may remove additional files, such as external
# libraries installed locally.
#
# Specifically, this removes all files that are git-ignored. New source files
# are preserved, so this command is considered safe.
#
.PHONY: gitclean
gitclean:
	git clean -dfX
	git submodule foreach --recursive git clean -dfX
