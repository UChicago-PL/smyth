#!/bin/bash

# To be run from the root directory of the project

make clean
scp -r -P 5555 * artifact@localhost:/home/artifact/smyth
