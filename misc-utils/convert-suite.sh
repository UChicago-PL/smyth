#!/bin/bash

mkdir fresh_dir || exit 1

gcsplit --suppress-matched -s -z $1 '/`````/' '{*}'

for f in $(ls -p | grep -v /); do
  if [[ $f =~ x ]]; then
    mv $f r_$(head -1 $f).elm
  fi
done

for f in $(ls -p | grep -v /); do
  if [[ $f =~ r_ ]]; then
    gsed -i '1d' $f
    mv $f fresh_dir
  fi
done

cd fresh_dir
rename 's/r_//' *
