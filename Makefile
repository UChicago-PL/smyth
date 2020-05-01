build:
	dune build src/main.exe

serve:
	make build && python3 serve.py

repl:
	dune utop lib/smyth

clean:
	dune clean

deps:
	opam install \
		utop dune yojson ppx_deriving ppx_deriving_yojson bark

loc:
	find lib src -name "*.ml" | xargs wc -l

loci:
	find lib src -name "*.ml*" | xargs wc -l

smythloc:
	find lib/smyth -name "*.ml" | xargs wc -l

smythloci:
	find lib/smyth -name "*.ml*" | xargs wc -l
