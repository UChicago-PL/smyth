#!/bin/bash

./smyth test \
  suites/complete-examples/$2.elm \
  suites/suite-$1/$2.elm \
  suites/suite-$1/examples/$2.elm
