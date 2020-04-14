# Smyth

## Building and Running

***Important note:***
Smyth is built with OCaml v4.08.1. When first working with the Smyth codebase,
please run `make deps` to download all the necessary opam dependencies.

For best performance, please use an installation of OCaml that supports
[flambda](https://caml.inria.fr/pub/docs/manual-ocaml/flambda.html)
(e.g. `4.08.1+flambda` obtained via `opam switch create 4.08.1+flambda`).

***To build and run the server:***
From the root directory of the project (where this `README` is), run `make
serve`.
The server (which is implemented in Python in `serve.py` and calls the
Smyth executable) will be hosted on port 9090.

***To build without running:***
From the root directory of the project (where this `README` is), run `make
build`.  This command creates the Smyth executable in
`_build/default/src/main.exe`, which is accessible via the `smyth` symlink in
the root directory of the project.

## OCaml Module Conventions

The library `Stdlib2` found in the [`lib/stdlib2/`](lib/stdlib2/) directory
contains modules that extend the functionality of the regular OCaml standard
library. The module [`Pervasives2`](lib/stdlib2/pervasives2.mli) found in this
library contains a small set of core functions and is automatically `open`ed in
every file.

The module [`Main`](src/main.ml) found in the [`src/`](src/) directory provides
a command-line interface to Smyth.

The library `Smyth` found in the [`lib/smyth/`](lib/smyth/) directory contains
all other source code for Smyth (i.e., the majority of the source code).

## Index

| Concept                                     | File (in [`lib/smyth/`](lib/smyth/))
| ------------------------------------------- | ------------------------------
| Syntax of Core Smyth                        | [`lang.ml`](lib/smyth/lang.ml)
| Result classification                       | [`res.mli`](lib/smyth/res.mli)/[`res.ml`](lib/smyth/res.ml)
| Type checking                               | In Elm codebase
| Type equality                               | [`type.mli`](lib/smyth/type.mli)/[`type.ml`](lib/smyth/type.ml)
| Evaluation                                  | [`eval.mli`](lib/smyth/eval.mli)/[`eval.ml`](lib/smyth/eval.ml)
| Resumption                                  | [`eval.mli`](lib/smyth/eval.mli)/[`eval.ml`](lib/smyth/eval.ml)
| Example syntax                              | [`lang.ml`](lib/smyth/lang.ml)
| Result-value coercions                      | [`res.mli`](lib/smyth/res.mli)/[`res.ml`](lib/smyth/res.ml)
| Example-value coercions                     | [`example.mli`](lib/smyth/example.mli)/[`example.ml`](lib/smyth/example.ml)
| Example satisfaction                        | [`example.mli`](lib/smyth/example.mli)/[`example.ml`](lib/smyth/example.ml)
| Constraint syntax                           | [`lang.ml`](lib/smyth/lang.ml)
| Constraint satisfaction                     | [`constraints.mli`](lib/smyth/constraints.mli)/[`constraints.ml`](lib/smyth/constraints.ml)
| Constraint merging                          | [`constraints.mli`](lib/smyth/constraints.mli)/[`constraints.ml`](lib/smyth/constraints.ml)
| Live bidirectional example checking         | [`uneval.mli`](lib/smyth/uneval.mli)/[`uneval.ml`](lib/smyth/uneval.ml)
| Example unevaluation                        | [`uneval.mli`](lib/smyth/uneval.mli)/[`uneval.ml`](lib/smyth/uneval.ml)
| Result consistency                          | [`res.mli`](lib/smyth/res.mli)/[`res.ml`](lib/smyth/res.ml)
| Assertion satisfaction and simplification   | [`uneval.mli`](lib/smyth/uneval.mli)/[`uneval.ml`](lib/smyth/uneval.ml)
| Constraint simplification                   | [`solve.mli`](lib/smyth/solve.mli)/[`solve.ml`](lib/smyth/solve.ml)
| Constraint solving                          | [`solve.mli`](lib/smyth/solve.mli)/[`solve.ml`](lib/smyth/solve.ml)
| Hole filling                                | [`fill.mli`](lib/smyth/fill.mli)/[`fill.ml`](lib/smyth/fill.ml)
| Type-and-example-directed refinement        | [`refine.mli`](lib/smyth/refine.mli)/[`refine.ml`](lib/smyth/refine.ml)
| Type-and-example-directed branching         | [`branch.mli`](lib/smyth/branch.mli)/[`branch.ml`](lib/smyth/branch.ml)
| Type-directed guessing (term generation)    | [`term_gen.mli`](lib/smyth/term_gen.mli)/[`term_gen.ml`](lib/smyth/term_gen.ml)
