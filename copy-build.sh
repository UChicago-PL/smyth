#!/bin/bash

[[ -f smyth.js ]] && rm smyth.js

cp _build/default/src/main.bc.js smyth.js

[[ -d docs ]] && rm -rf docs

cp -r _build/default/_doc/_html docs
