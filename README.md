# Artifact Evaluation

### Program Sketching with Live Bidirectional Evaluation

_Justin Lubin, Nick Collins, Cyrus Omar, and Ravi Chugh._

Thank you for taking the time to review our artifact!

Unzipping the `smyth.tar.gz` file will yield a directory named `smyth/`, which
contains all the code used for the implementation and evaluation of Smyth, the
programming-by-example tool detailed in our ICFP submission.

If you are using the virtual machine image that we have provided, then please
skip the installation instructions, as Smyth has already been installed.

## Installation

1. Install `opam`, the OCaml package manager:

     https://opam.ocaml.org/doc/Install.html

2. Install OCaml 4.08.1 with the
   [flambda](https://caml.inria.fr/pub/docs/manual-ocaml/flambda.html)
   optimizer by running `opam switch create 4.08.1+flambda`.

3. Run `make deps` in the `smyth/` directory to download all the necessary opam
   dependencies.

4. Run `make` to build the Smyth executable. The executable is accessible via
   the `smyth` symlink in the `smyth/` directory.

For the data collection and analysis, you will also need the following tools
installed:

  - GNU Octave (https://www.gnu.org/software/octave/)
  - LaTeX
  - Python 2.7
  - Python 3

## Things to Try Out

We believe there are several main areas of exploration to help best evaluate
Smyth:

1. Viewing the updated experimental results
2. Running the benchmark suite
3. Inspecting the output of the synthesis procedure
4. Skimming the codebase

### 1. Viewing the updated experimental results

The `smyth/experiments/latex-tables/smyth-experiment-tables-ours.pdf` document
describes our latest experimental results, described in detail with respect to
Figure 10 in our submission.

### 2. Running the benchmark suite

_*Quick summary*: navigate to `smyth/experiments/`, run `./run-all 10`, look at
`smyth/experiments/latex-tables/smyth-experiment-tables.pdf`_

To run all the data collection and analysis for Smyth, navigate to the
`smyth/experiments/` directory and run the script `run-all`, which takes a
positive integer `N` as an argument that indicates how many trials per
example-set size to run for each benchmark in Experiment 2b and 3b (the
randomized experiments).

We ran these experiments with `N = 50` (that is, `./run-all 50`), which takes
about 2 to 2.5 hours to run on a Mid 2012 MacBook Pro with a 2.5 GHz Intel Core
i5 CPU and 16 GB of RAM.

If you would prefer to get the results faster (at the loss of statistical
precision), we would recommend running the experiments with `N = 10` (that is,
`./run-all 10`), which takes about 30 minutes to run on the same MacBook.

Once this script is complete, you can take a look at the results with any
phenomena of note explained in
`smyth/experiments/latex-tables/smyth-experiment-tables.pdf`.

*Note:* Rarely, due to timing issues with the UNIX Timer API, one of the
benchmarks might crash with a "Timeout" exception during Experiments 2b and 3b.
Even more rarely, a stack overflow error might occur. To combat these
situations, the Experiment 2b and 3b scripts automatically retry a benchmark on
unexpected failure.

### 3. Inspecting the output of the synthesis procedure

To interact with the synthesizer more directly, you can navigate to the `smyth/`
directory and run the `./smyth forge` command. This command takes one argument:
the sketch to be completed ("forged").

We have provided the six sketches described in Sections 1 and 2 of our paper in
the `examples/` directory so that you can, for example, run `./smyth forge
examples/stutter.elm` from the `smyth/` directory to see the output. Feel free
to change the input-output examples on these sketches (or the program sketches
themselves) to see how `smyth` responds. You can also create your own files
following the same Syntax (mostly Elm) to try out.

By default `./smyth forge` only shows the top solution, but after all the other
arguments, you can pass in the flag `--show=top1r` or `--show=top3` to show the
top recursive solution or top three overall solutions, respectively.

The benchmark sketches are stored in `smyth/suites/SUITE_NAME/sketches` and the
input-examples used for those sketches are stored in
`smyth/suites/SUITE_NAME/examples`. If you want to see the actual synthesis
output on just one of these sketches, you can use the `forge` helper script that
we have provided in the `smyth/` directory as follows:

  `./forge <top1|top1r|top3> <suite-name> <sketch-name>`

So, for example, you could run

  `./forge top1 no-sketch list_sorted_insert`

to see the top result of running the `list_sorted_insert` benchmark from the
`no-sketch` suite.

### 4. Skimming the codebase

The following table provides a roadmap of where each concept/figure in the paper
can be found in the codebase, in order of presentation in the paper.

To see how these all fit together with actual code, you can view the "synthesis
pipeline" in [`endpoint.ml`](smyth/lib/smyth/endpoint.ml) (specifically, the `solve`
function).

| Concept/Figure                              | File (in [`smyth/lib/smyth/`](smyth/lib/smyth/))
| ------------------------------------------- | ------------------------------
| Syntax of Core Smyth                        | [`lang.ml`](smyth/lib/smyth/lang.ml)
| Type checking                               | [`type.mli`](smyth/lib/smyth/type.mli)/[`type.ml`](smyth/lib/smyth/type.ml)
| Expression evaluation                       | [`eval.mli`](smyth/lib/smyth/eval.mli)/[`eval.ml`](smyth/lib/smyth/eval.ml)
| Resumption                                  | [`eval.mli`](smyth/lib/smyth/eval.mli)/[`eval.ml`](smyth/lib/smyth/eval.ml)
| Example satisfaction                        | [`example.mli`](smyth/lib/smyth/example.mli)/[`example.ml`](smyth/lib/smyth/example.ml)
| Constraint satisfaction                     | [`constraints.mli`](smyth/lib/smyth/constraints.mli)/[`constraints.ml`](smyth/lib/smyth/constraints.ml)
| Constraint merging                          | [`constraints.mli`](smyth/lib/smyth/constraints.mli)/[`constraints.ml`](smyth/lib/smyth/constraints.ml)
| Live bidirectional example checking         | [`uneval.mli`](smyth/lib/smyth/uneval.mli)/[`uneval.ml`](smyth/lib/smyth/uneval.ml)
| Example unevaluation                        | [`uneval.mli`](smyth/lib/smyth/uneval.mli)/[`uneval.ml`](smyth/lib/smyth/uneval.ml)
| Program evaluation                          | [`eval.mli`](smyth/lib/smyth/eval.mli)/[`eval.ml`](smyth/lib/smyth/eval.ml)
| Result consistency                          | [`res.mli`](smyth/lib/smyth/res.mli)/[`res.ml`](smyth/lib/smyth/res.ml)
| Assertion satisfaction and simplification   | [`uneval.mli`](smyth/lib/smyth/uneval.mli)/[`uneval.ml`](smyth/lib/smyth/uneval.ml)
| Constraint simplification                   | [`solve.mli`](smyth/lib/smyth/solve.mli)/[`solve.ml`](smyth/lib/smyth/solve.ml)
| Constraint solving                          | [`solve.mli`](smyth/lib/smyth/solve.mli)/[`solve.ml`](smyth/lib/smyth/solve.ml)
| Type-and-example-eirected hole synthesis    | [`fill.mli`](smyth/lib/smyth/fill.mli)/[`fill.ml`](smyth/lib/smyth/fill.ml)
| Type-directed guessing (term generation)    | [`term_gen.mli`](smyth/lib/smyth/term_gen.mli)/[`term_gen.ml`](smyth/lib/smyth/term_gen.ml)
| Type-and-example-directed refinement        | [`refine.mli`](smyth/lib/smyth/refine.mli)/[`refine.ml`](smyth/lib/smyth/refine.ml)
| Type-and-example-directed branching         | [`branch.mli`](smyth/lib/smyth/branch.mli)/[`branch.ml`](smyth/lib/smyth/branch.ml)
