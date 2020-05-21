# Artifact Evaluation

### Program Sketching with Live Bidirectional Evaluation

_Justin Lubin, Nick Collins, Cyrus Omar, and Ravi Chugh._

This repository contains all the code used for the implementation and evaluation
of Smyth, the programming-by-example tool detailed in our ICFP submission.

If you are using the virtual machine image that we have provided, then please
skip the installation instructions, as Smyth has already been installed.

## Installation

1. Install `opam`, the OCaml package manager:

     https://opam.ocaml.org/doc/Install.html

2. Install OCaml 4.08.1 with the
   [flambda](https://caml.inria.fr/pub/docs/manual-ocaml/flambda.html)
   optimizer by running `opam switch create 4.08.1+flambda`.

3. Run `make deps` in the root directory of this project to download all the
   necessary opam dependencies.

4. Run `make` to build the Smyth executable. The executable is accessible via
   the `smyth` symlink in the root directory of this project.

For the data collection and analysis, you will also need the following tools
installed:

  - GNU Octave (https://www.gnu.org/software/octave/)
  - LaTeX
  - Python 2.7
  - Python 3

## Things to Try Out

We believe there are three main areas of exploration that will be help you best
evaluate Smyth. They are:

1. Running the benchmark suite
2. Inspecting the output of the synthesis procedure
3. Skimming the codebase

Here's how to do each of the following:

### 1. Running the benchmark suite

_*Quick summary*: navigate to `experiments/`, run `./run-all 10`, look at
`experiments/latex-tables/smyth-experiment-tables.pdf`_

To run all the data collection and analysis for Smyth, navigate to the
`experiments/` directory and run the script `run-all`, which takes a positive
integer `N` as an argument that indicates how many trials per example-set size
to run for each benchmark in Experiment 2b and 3b (the randomized experiments).

We ran these experiments with `N = 50` (that is, `./run-all 50`), which takes
about 2 to 2.5 hours to run on a Mid 2012 MacBook Pro with a 2.5 GHz Intel Core
i5 CPU and 16 GB of RAM.

If you would prefer to get the results faster (at the loss of statistical
precision), we would recommend running the experiments with `N = 10` (that is,
`./run-all 10`), which takes about TODO minutes to run on the same Macbook.

Once this script is complete, you can take a look at the results with any
phenomena of note explained in
`experiments/latex-tables/smyth-experiment-tables.pdf`.

*Note:* Rarely, due to timing issues with the UNIX Timer API, one of the
benchmarks might crash with a "Timeout" exception during Experiments 2b and 3b.
Even more rarely, a stack overflow error might occur. To combat these
situations, the Experiment 2b and 3b scripts automatically retry a benchmark on
unexpected failure.

### 2. Inspecting the output of the synthesis procedure

To interact with the synthesizer more directly, you can run the `./smyth forge`
command in the root directory of the project. This command takes one argument:
the sketch to be completed ("forged").

We have provided the six sketches described in Sections 1 and 2 of our paper in
the `examples/` directory so that you can, for example, run `./smyth forge
examples/stutter.elm` to see the output. Feel free to change the input-output
examples on these sketches (or the program sketches themselves) to see how
`smyth` responds. You can also create your own files following the same Syntax
(mostly Elm) to try out.

By default `./smyth forge` only shows the top solution, but after all the other
arguments, you can pass in the flag `--show=top1r` or `--show=top3` to show the
top recursive solution or top three overall solutions, respectively.

The benchmark sketches are stored in `suites/SUITE_NAME/sketches` and the
input-examples used for those sketches are stored in
`suites/SUITE_NAME/examples`. If you want to see the actual synthesis output on
just one of these sketches, you can use the `forge` helper script that we have
provided in the root directory of this project as follows:

  `./forge <top1|top1r|top3> <suite-name> <sketch-name>`

So, for example, you could run

  `./forge top1 no-sketch list_sorted_insert`

to see the top result of running the `list_sorted_insert` benchmark from the
`no-sketch` suite.

### 3. Skimming the codebase

The following table provides a roadmap of where each concept/figure in the paper
can be found in the codebase, in order of presentation in the paper.

To see how these all fit together with actual code, you can view the "synthesis
pipeline" in [`endpoint.ml`](lib/smyth/endpoint.ml) (specifically, the `solve`
function).

| Concept/Figure                              | File (in [`lib/smyth/`](lib/smyth/))
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
| Type-and-example-eirected hole synthesis    | [`fill.mli`](lib/smyth/fill.mli)/[`fill.ml`](lib/smyth/fill.ml)
| Type-directed guessing (term generation)    | [`term_gen.mli`](lib/smyth/term_gen.mli)/[`term_gen.ml`](lib/smyth/term_gen.ml)
| Type-and-example-directed refinement        | [`refine.mli`](lib/smyth/refine.mli)/[`refine.ml`](lib/smyth/refine.ml)
| Type-and-example-directed branching         | [`branch.mli`](lib/smyth/branch.mli)/[`branch.ml`](lib/smyth/branch.ml)
