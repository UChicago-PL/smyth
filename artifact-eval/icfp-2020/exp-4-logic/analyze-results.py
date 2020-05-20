#!/usr/bin/python   # Python 2.7

import myth_benchmarks
  # TODO
  # make sure myth_benchmarks.py is in the same directory,
  # or is symlinked to experiments/myth_benchmarks.py
import re
from operator import itemgetter


def listConcat(xss):
  return [ x for xs in xss for x in xs ]

benchmarks = \
  listConcat (
    [ myth_benchmarks.bool_benchmarks
    , myth_benchmarks.list_benchmarks
    , myth_benchmarks.nat_benchmarks
    , myth_benchmarks.tree_benchmarks
    ]
  )

print "#Benchmarks:", len(benchmarks)

def generate_summary(tool_name, which_examples):
  output_filename =            \
    "results/summaries/exp-4-" \
      + tool_name + "-"        \
      + which_examples + ".csv"
  output = open(output_filename, "w")

  def write(name, string):
    output.write(",".join([name,string]) + "\n")

  for benchmark in benchmarks:
    name = benchmark[0]
    input_filename =           \
      "results/"               \
        + which_examples + "/" \
        + tool_name + "_" + name + ".txt"
    try:
      f = open(input_filename, "r")
      lines = f.readlines()

      if len(lines) == 0:
        print "[" + input_filename + "] is empty"

      else:
        last_line = lines[-1]
        if last_line.startswith("Correct"):
          write(name, "\\leonquidCorrect")
        elif last_line.startswith("Incorrect"):
          write(name, "\\leonquidIncorrect")
        elif last_line.startswith("Error"):
          write(name, "\\leonquidError")
        elif last_line.startswith("N/A"):
          write(name, "\\leonquidBlank")
        else:
          write(name, "XXX last_line")

    except IOError:
      print "[" + input_filename + "] not found"

generate_summary("leon", "1")
generate_summary("leon", "2a")
generate_summary("synquid", "1")
generate_summary("synquid", "2a")
