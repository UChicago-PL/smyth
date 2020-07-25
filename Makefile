.PHONY: build
build:
	dune build src/main.exe

.PHONY: bc
bc:
	dune build src/main.bc

.PHONY: js
js:
	dune build src/main.bc.js

.PHONY: doc
doc:
	dune build @doc \
		&& ./misc-utils/modify-odoc-css.sh \
		&& ./misc-utils/add-module-overviews.sh

.PHONY: all
all:
	make build; make bc; make js; make doc

.PHONY: publish
publish:
	make all; git checkout gh-pages; ./copy.sh; \
		git add -A; git commit -m "Pull updates from 'main'"; git push; \
		git checkout main

.PHONY: repl
repl:
	dune utop lib/smyth

.PHONY: clean
clean:
	dune clean

.PHONY: deps
deps:
	opam install \
		utop dune bark \
		js_of_ocaml js_of_ocaml-compiler js_of_ocaml-ppx

.PHONY: loc
loc:
	find lib src -name "*.ml" | xargs wc -l

.PHONY: loci
loci:
	find lib src -name "*.ml*" | xargs wc -l

.PHONY: smythloc
smythloc:
	find lib/smyth -name "*.ml" | xargs wc -l

.PHONY: smythloci
smythloci:
	find lib/smyth -name "*.ml*" | xargs wc -l
