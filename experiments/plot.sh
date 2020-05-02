#!/bin/bash

if [[ $# -ne 3 ]]; then
  echo "usage:" $0 "suite N timeout"
  exit 1
fi

cd $1

gcsplit -s -z $1.txt '/N =/-1' '{*}'

rm -rf csv
rm -rf png

mkdir csv
mkdir png

if [[ $1 =~ ^sketch ]]; then
  kind="BaseCaseSketch"
elif [[ $1 =~ ^nosketch ]]; then
  kind="NoSketch"
else
  kind="UNKNOWN"
fi

for file in xx*; do
  name=$(head -1 $file)
  tail -n +2 $file > csv/$name.csv
  octave --no-gui ../smyth_plot.m $name $2 $3 $kind
  rm $file
done
