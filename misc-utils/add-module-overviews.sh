#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

python3 $DIR/add_module_overviews.py "_build/default/_doc/_html" \
  > _build/default/_doc/_html/smyth/Smyth/index2.html

mv _build/default/_doc/_html/smyth/Smyth/index2.html \
   _build/default/_doc/_html/smyth/Smyth/index.html
