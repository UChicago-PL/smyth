#!/bin/bash

## Script used to display summaries during Leon and Synquid experiments.
##
## Manual steps for {leon,synquid} * {1,2a}, shown for synquid 1:
##
## First, 
##      cp generated/1/synquid_* results/1/
##      cd results/
##      ls synquid*
##
## Then, process each benchmark:
##   1. F=bool_bor && (cat synquid_$F.txt | pbcopy) && vim synquid_$F.txt
##   2. paste in web editor
##   3. copy solution at end of (already-opened) synquid_$F.txt buffer
##   4. add classification label on last line
##
## So, our labeled results are in:
##   results/1/leon_*.txt*
##   results/2a/leon_*.txt*
##   results/1/synquid_*.txt*
##   results/2a/synquid_*.txt*

show() {
  FILES="results/$3/$2_*.txt*"
  echo ""
  echo "$1 $4"
  echo "-----------------------------------"
  echo "#Correct     " `grep '^Correct.*$' $FILES | wc -l`
  echo "#Incorrect   " `grep '^Incorrect.*$' $FILES | wc -l`
  echo "#Error       " `grep '^Error.*$' $FILES | wc -l`
  echo "#TODO        " `grep '^TODO.*$' $FILES | wc -l`
  echo "#N/A         " `grep '^N/A$' $FILES | wc -l`
  echo "#Total       " `grep '^Correct.*\|^Incorrect.*\|^Error.*\|^TODO\|^N/A$' $FILES | wc -l` "/" `ls -l $FILES | wc -l`
}

show Leon    leon    1  '(1: Myth Expert Examples)'
show Leon    leon    2a '(2a: Smyth Expert Examples)'
show Synquid synquid 1  '(1: Expert Examples)'
show Synquid synquid 2a '(2a: Smyth Expert Examples)'
