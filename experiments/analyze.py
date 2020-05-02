#!/usr/bin/env python3

import sys
import glob
import os
import csv

if len(sys.argv) != 2:
    print("usage:", sys.argv[0], "suite")
    sys.exit(1)

suite = sys.argv[1]

prefix = ""
if suite.startswith("sketch"):
    prefix = "1+"

def show_k(k):
    if k:
        return prefix + str(k)
    else:
        return "---"

print("task,k50,k90")
for filename in glob.glob(suite + "/csv/*.csv"):
    k90 = None
    k50 = None
    with open(filename) as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        # Skip first two rows
        next(reader)
        next(reader)
        k50 = 0
        k90 = 0
        kMax = 0
        for row in reader:
            kMax += 1
            k = int(row[0])
            p = float(row[1])
            if p < 0.5:
                k50 = k
            if p < 0.9:
                k90 = k
        k50 += 1
        k90 += 1
        if k50 > kMax:
            k50 = None
        if k90 > kMax:
            k90 = None
    task = os.path.basename(filename[:-4])
    print(task, show_k(k50), show_k(k90), sep=",")
