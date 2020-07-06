build:
	dune build src/main.exe

bc:
	dune build src/main.bc

js:
	dune build src/main.bc.js

repl:
	dune utop lib/smyth

clean:
	dune clean

deps:
	opam install \
		utop dune yojson ppx_deriving ppx_deriving_yojson bark js_of_ocaml-compiler

loc:
	find lib src -name "*.ml" | xargs wc -l

loci:
	find lib src -name "*.ml*" | xargs wc -l

smythloc:
	find lib/smyth -name "*.ml" | xargs wc -l

smythloci:
	find lib/smyth -name "*.ml*" | xargs wc -l
