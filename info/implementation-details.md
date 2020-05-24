# Implementation Details and Optimizations

For the most part, the algorithm described in our ICFP 2020 publication,
_Program Sketching with Live Bidirectional Evaluation_, translates quite
directly to OCaml code. The exact mapping between concepts and code can be seen
in the table in the `README.md` file in the root directory of this project.

However, there are some aspects of the algorithm that necessitate necessitate a
choice on behalf of the implementation. In some cases, theses choices can have a
large impact on usability, performance, and accuracy. This document details the
choices that we have settled on for this particular implementation of the
algorithm described in the aforementioned paper and our rationale as to why we
made these choices.

The theory of Smyth is based on the research detailed in [Peter-Michael
Osera](https://iampmo.com/)'s PhD thesis, which presents its own implementation
of a program synthesizer by the name of "Myth." In this document, we refer to
this thesis as "the Myth thesis."

## Strategies inherited from Myth

This section details the implementation details and optimizations that Smyth
inherits from Myth.

### Termination checking

Myth employs a check during program synthesis to ensure that all recursive calls
are _structurally decreasing_, that is, that the argument to a recursive
function recursive call is a strict subterm of the parameter to the recursive
call.

We employ this same restriction. One limitation of this approach (as
implemented) arises from the fact that all functions in Smyth have exactly one
parameter (multi-parameter functions are curried). As a consequence, only
recursive calls that are structurally decreasing on the "first" argument of
multi-parameter (curried) functions are accepted as valid.

To get around this issue, some of the sketches in our benchmark suites have
unconvential ordering of parameters or internal helper functions with one
argument.

### Timeouts

Myth cuts off term enumeration after a small amount of time has passed
(0.25s). Smyth does, too (also after 0.25s). More details about the parameters
that Smyth relies on for synthesis are described in the "Tuning Parameters"
section below.

Myth and Smyth also both cut off the overall synthesis procedure if too much
time has elapsed for tool usability reasons.

### Staged synthesis plan

Myth employs a staged approach to program synthesis whereby specific search
parameters begin at highly restricted values and are gradually relaxed as the
search with these parameters fails until the search finally succeeds (or times
out).

The paramters that undergo this progressive staging (known as the "synthesis
plan") are:

- _Match depth_, or, how many nested `case` expressions the synthesizer is
  allowed to synthesize;
- _Scrutinee size_, or, how large the AST of the scrutinee of the generated
  `case` expressions can be; and
- _Guessed term size_, or, how large the AST of the terms that are produced by
  type-directed term guessing (i.e. "term generation" or "term enumeration")
  without the guidance from examples can be.

Smyth follows the same approach and nearly the same synthesis plan as Myth
(albeit with slightly more granular stages). The Myth synthesis plan was
determined experimentally, and so too was the Smyth synthesis plan.

See Appendix A of the Myth thesis for more details.

### Informativeness restriction

Section 7.3.2 of the Myth thesis details how to cut down on redundant pattern
matching (an important concern because `case` expressions introduce a high
degree of nondeterminism in both Myth and Smyth) by introducing an
"informativeness restriction." Smyth follows suit with the same restriction,
which disallows pattern matching when fewer than two of the branches get
new examples distributed to them (that is, when pattern matching actually does
not produce any "new information").

Notably, this restriction prevents underspecification of functions that might
actually be desirable. For example, synthesis of the function
`listHead : List a -> a` with the assertion `assert listHead [1, 2] == 1` might
reasonably be expected to produce the following result:

```elm
listHead : List a -> a
listHead xs =
  case xs of
    [] ->
      ??

    y :: _ ->
      y
```

However, only the non-empty case of this pattern match has an example
distributed to it, so this case expression is not synthesized.

This tradeoff was chosen because the immense performance benefit of the
informativeness restriction allows a much broader class of programs to be
synthesized, while only sacrificing the ability to synthesize underspecified
functions slightly more cleverly.

### Cached term enumeration

In Section 7.3.4, the Myth thesis details how to achieve efficient raw term
enumeration based on a careful caching strategy. We follow the same strategy for
term enumeration in Smyth.
