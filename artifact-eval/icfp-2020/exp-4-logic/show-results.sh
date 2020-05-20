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

echo ""
echo "Leon (1 Expert Examples)"
echo "----------------------------"
echo "#Correct     " `grep '^Correct.*$' results/1/leon_*.txt* | wc -l`
echo "#Incorrect   " `grep '^Incorrect.*$' results/1/leon_*.txt* | wc -l`
echo "#Error       " `grep '^Error.*$' results/1/leon_*.txt* | wc -l`
echo "#TODO        " `grep '^TODO.*$' results/1/leon_*.txt* | wc -l`
echo "#Total       " `grep '^Correct.*\|^Incorrect.*\|^Error.*\|^TODO\|^N/A$' results/1/leon_*.txt* | wc -l` "/" `ls -l results/1/leon_*.txt | wc -l`

echo ""
echo "Leon (2a Expert Examples)"
echo "----------------------------"
echo "#Correct     " `grep '^Correct.*$' results/2a/leon_*.txt* | wc -l`
echo "#Incorrect   " `grep '^Incorrect.*$' results/2a/leon_*.txt* | wc -l`
echo "#Error       " `grep '^Error.*$' results/2a/leon_*.txt* | wc -l`
echo "#TODO        " `grep '^TODO.*$' results/2a/leon_*.txt* | wc -l`
echo "#N/A         " `grep '^N/A$' results/2a/leon_*.txt* | wc -l`
echo "#Total       " `grep '^Correct.*\|^Incorrect.*\|^Error.*\|^TODO\|^N/A$' results/2a/leon_*.txt* | wc -l` "/" `ls -l results/2a/leon_*.txt | wc -l`

echo ""
echo "Synquid (1 Expert Examples)"
echo "----------------------------"
echo "#Correct     " `grep '^Correct.*$' results/1/synquid_*.txt* | wc -l`
echo "#Incorrect   " `grep '^Incorrect.*$' results/1/synquid_*.txt* | wc -l`
echo "#Error       " `grep '^Error.*$' results/1/synquid_*.txt* | wc -l`
echo "#TODO        " `grep '^TODO.*$' results/1/synquid_*.txt* | wc -l`
echo "#Total       " `grep '^Correct.*\|^Incorrect.*\|^Error.*\|^TODO\|^N/A$' results/1/synquid_*.txt* | wc -l` "/" `ls -l results/1/synquid_*.txt | wc -l`

echo ""
echo "Synquid (2a Expert Examples)"
echo "----------------------------"
echo "#Correct     " `grep '^Correct.*$' results/2a/synquid_*.txt* | wc -l`
echo "#Incorrect   " `grep '^Incorrect.*$' results/2a/synquid_*.txt* | wc -l`
echo "#Error       " `grep '^Error.*$' results/2a/synquid_*.txt* | wc -l`
echo "#TODO        " `grep '^TODO.*$' results/2a/synquid_*.txt* | wc -l`
echo "#N/A         " `grep '^N/A$' results/2a/synquid_*.txt* | wc -l`
echo "#Total       " `grep '^Correct.*\|^Incorrect.*\|^Error.*\|^TODO\|^N/A$' results/2a/synquid_*.txt* | wc -l` "/" `ls -l results/2a/synquid_*.txt | wc -l`
