#!/bin/bash

./plot.sh nosketch 50 1
./analyze.py nosketch > nosketch/analysis.csv

./plot.sh sketch 50 1
./analyze.py sketch > sketch/analysis.csv

./plot.sh nosketch3s 50 3
./analyze.py nosketch3s > nosketch3s/analysis.csv

./plot.sh nosketch10s 50 10
./analyze.py nosketch10s > nosketch10s/analysis.csv

./plot.sh sketch10s 50 10
./analyze.py sketch10s > sketch10s/analysis.csv
