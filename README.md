# Smyth

Smyth is a program synthesizer that will fill in "holes" in a program in a
typed, functional language (approximately [Elm](https://elm-lang.org) in our
formulation) when given input-output examples, or, more generally, arbitrary
assertions about the behavior of the code. These assertions are just "normal
code" and can serve as unit tests once the synthesis has completed.

Evaluation of these assertions internally gives rise to input-output examples
which, along with the types in the program, guide the synthesis search to fill
in the holes. The key technical innovation, _live bidirectional evaluation_,
propagates examples "backward" through partially evaluated _sketches_ (that is,
programs with holes).

Live bidirectional evaluation enables Smyth not only to specify and solve
interdependent synthesis goals over holes at arbitrary locations in the program,
it also removes the need to specify "trace-complete" sets of examples recursive
functions (that is, sets of examples that mirror the intended recursive behavior
of the function to be synthesized), a major limitation of prior work on
evaluator-based synthesis.

The name "Smyth" is a portmanteau of "sketching" and "Myth" (the
type-and-example directed program synthesizer upon which the theory of Smyth is
based). It was coined by [Robert Rand](https://www.cs.umd.edu/~rrand/) who,
incidentally, also coined the name "Myth."

## Additional Resources

- A formal exposition of the system (including its evaluation and underlying
theory) can be found in our ICFP 2020 publication, [_Program Sketching with Live
Bidirectional Evaluation_](https://arxiv.org/abs/1911.00583).

- A non-academic introduction to the Smyth project can be found on the
[project webpage](https://uchicago-pl.github.io/smyth).

- Code documentation for the system can be found
[here](https://uchicago-pl.github.io/smyth/docs). The
documentation for the core synthesis algorithm as outlined in our ICFP
2020 publication specifically can be found in the
[smyth/Smyth/](https://uchicago-pl.github.io/smyth/docs/smyth/Smyth/index.html)
subdirectory. The [codebase section](#the-codebase) below gives a high-level
overview of the system.

- Further details about the implementation of Smyth can be found in Justin Lubin's
undergraduate thesis, [_Forging Smyth: The Implementation of Program Sketching with
Live Bidirectional Evaluation_](https://jlubin.net/assets/forging-smyth.pdf).

## Installation

1. Install [`opam`](https://opam.ocaml.org/doc/Install.html), the OCaml package
   manager.

2. Install OCaml 4.08.1 with the
   [flambda](https://caml.inria.fr/pub/docs/manual-ocaml/flambda.html) optimizer
   by running `opam switch create 4.08.1+flambda`. OCaml versions after 4.08.1
   should work fine too, but are untested.

3. Run `make deps` in the root directory of this project to download all the
   necessary `opam` dependencies.

4. Run `make` to build the Smyth executable. The executable is accessible via
   the `smyth` symlink in the root directory of this project.

To replicate the experiments we have run to evaluate Smyth, you will also need
the following tools installed:

  - GNU Octave
  - LaTeX
  - Python 2.7
  - Python 3

To modify the documentation, you will also need the following tools installed:

  - BeautifulSoup 4

The benchmark sketches from the experimental evaluation of Smyth are stored in
`suites/SUITE_NAME/sketches` and the input-examples used for those sketches are
stored in `suites/SUITE_NAME/examples`. If you want to see the actual
synthesis output on just one of these sketches, you can use the `forge` helper
script that we have provided in the root directory of this project as follows:

  `./forge <top1|top1r|top3> <suite-name> <sketch-name>`

So, for example, you could run

  `./forge top1 no-sketch list_sorted_insert`

to see the top result of running the `list_sorted_insert` benchmark from the
`no-sketch` suite.

### Updates

_August 20, 2020:_ A new release, `icfp-2020-v1` includes module-level
documentation for the `smyth` library and fixes a bug that caused
Experiments 2b and 3b to fail to run.

## Running the Experimental Evaluation

_*Quick summary*: navigate to `experiments/`, run `./run-all 10`, look at
`/experiments/latex-tables/smyth-experiment-tables.pdf`_

To run all the data collection and analysis for Smyth as described in our ICFP
paper, navigate to the `experiments/` directory and run the script `run-all`,
which takes a positive integer `N` as an argument that indicates how many trials
per example-set size to run for each benchmark in Experiment 2b and 3b (the
randomized experiments).

We ran these experiments with `N = 50` (that is, `./run-all 50`), which takes
about 2 to 2.5 hours to run on a Mid 2012 MacBook Pro with a 2.5 GHz Intel Core
i5 CPU and 16 GB of RAM.

If you would prefer to get the results faster (with the loss of statistical
precision), we would recommend running the experiments with `N = 10` (that is,
`./run-all 10`), which takes about 30 minutes to run on the same MacBook.

Once this script is complete, you can take a look at the results with any
phenomena of note explained in
`experiments/latex-tables/smyth-experiment-tables.pdf`.

*Note:* Rarely, due to timing issues with the UNIX Timer API, one of the
benchmarks that is not indicated as a failure might crash with a "Timeout"
exception during Experiments 2b and 3b.  Even more rarely, a stack overflow
error might occur. To combat these situations, the Experiment 2b and 3b scripts
automatically retry a benchmark on unexpected failure.

## The Codebase

The [`lib/smyth`](lib/smyth/) directory contains all the code for the core
implementation of the Smyth synthesis algorithm. The
[`lib/stdlib2`](lib/stdlib2/) directory contains helper functions that are used
throughout the codebase. The [`src/`](src/) directory contains the code relevant
to the command-line interface to Smyth, as well as some code that is used for
its experimental evaluation.

The following table provides a roadmap of where each concept/figure in the paper
can be found in the codebase, in order of presentation in the paper.

| Concept                                     | File (in [`lib/smyth/`](lib/smyth/))
| ------------------------------------------- | ------------------------------
| Syntax of Core Smyth                        | [`lang.ml`](lib/smyth/lang.ml)
| Type checking                               | [`type.mli`](lib/smyth/type.mli)/[`type.ml`](lib/smyth/type.ml)
| Expression evaluation                       | [`eval.mli`](lib/smyth/eval.mli)/[`eval.ml`](lib/smyth/eval.ml)
| Resumption                                  | [`eval.mli`](lib/smyth/eval.mli)/[`eval.ml`](lib/smyth/eval.ml)
| Example satisfaction                        | [`example.mli`](lib/smyth/example.mli)/[`example.ml`](lib/smyth/example.ml)
| Constraint satisfaction                     | [`constraints.mli`](lib/smyth/constraints.mli)/[`constraints.ml`](lib/smyth/constraints.ml)
| Constraint merging                          | [`constraints.mli`](lib/smyth/constraints.mli)/[`constraints.ml`](lib/smyth/constraints.ml)
| Live bidirectional example checking         | [`uneval.mli`](lib/smyth/uneval.mli)/[`uneval.ml`](lib/smyth/uneval.ml)
| Example unevaluation                        | [`uneval.mli`](lib/smyth/uneval.mli)/[`uneval.ml`](lib/smyth/uneval.ml)
| Program evaluation                          | [`eval.mli`](lib/smyth/eval.mli)/[`eval.ml`](lib/smyth/eval.ml)
| Result consistency                          | [`res.mli`](lib/smyth/res.mli)/[`res.ml`](lib/smyth/res.ml)
| Assertion satisfaction and simplification   | [`uneval.mli`](lib/smyth/uneval.mli)/[`uneval.ml`](lib/smyth/uneval.ml)
| Constraint simplification                   | [`solve.mli`](lib/smyth/solve.mli)/[`solve.ml`](lib/smyth/solve.ml)
| Constraint solving                          | [`solve.mli`](lib/smyth/solve.mli)/[`solve.ml`](lib/smyth/solve.ml)
| Type-and-example-directed hole synthesis    | [`fill.mli`](lib/smyth/fill.mli)/[`fill.ml`](lib/smyth/fill.ml)
| Type-directed guessing (term generation)    | [`term_gen.mli`](lib/smyth/term_gen.mli)/[`term_gen.ml`](lib/smyth/term_gen.ml)
| Type-and-example-directed refinement        | [`refine.mli`](lib/smyth/refine.mli)/[`refine.ml`](lib/smyth/refine.ml)
| Type-and-example-directed branching         | [`branch.mli`](lib/smyth/branch.mli)/[`branch.ml`](lib/smyth/branch.ml)

To see how these concepts all fit together with actual code, you can take a look
at the "synthesis pipeline" in [`lib/smyth/endpoint.ml`](lib/smyth/endpoint.ml)
(specifically, the `solve` function).
