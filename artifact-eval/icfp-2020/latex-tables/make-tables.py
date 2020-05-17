#!/usr/bin/python


################################################################################
## Names of Myth benchmark programs.

benchmarks_by_type = \
    [ [ "bool_band"
      , "bool_bor"
      , "bool_impl"
      , "bool_neg"
      , "bool_xor"
      ]
    , [ "list_append"
      , "list_compress"
      , "list_concat"
      , "list_drop"
      , "list_even_parity"
      , "list_filter"
      , "list_fold"
      , "list_hd"
      , "list_inc"
      , "list_last"
      , "list_length"
      , "list_map"
      , "list_nth"
      , "list_pairwise_swap"
      , "list_rev_append"
      , "list_rev_fold"
      , "list_rev_snoc"
      , "list_rev_tailcall"
      , "list_snoc"
      , "list_sort_sorted_insert"
      , "list_sorted_insert"
      , "list_stutter"
      , "list_sum"
      , "list_take"
      , "list_tl"
      ]
    , [ "nat_add"
      , "nat_iseven"
      , "nat_max"
      , "nat_pred"
      ]
    , [ "tree_binsert"
      , "tree_collect_leaves"
      , "tree_count_leaves"
      , "tree_count_nodes"
      , "tree_inorder"
      , "tree_map"
      , "tree_nodes_at_level"
      , "tree_postorder"
      , "tree_preorder"
      ]
    ]

benchmarks = \
    [ benchmark for list in benchmarks_by_type for benchmark in list ]

assert (len(benchmarks) == 43)


################################################################################
## Load dictionary of data in Figure 10 from submission.
##
## The file "latex-tables/figure-10-data.csv" is CSV version of
## the "latex-tables/figure-10-data.tex" rendered in our submission.
## The follow functions mirror some of the LaTeX macros.

def loadFigure10():
    table = {}
    for line in open("latex-tables/figure-10-data.csv"):
        line = line.strip()
        columns = line.split(",")
        if len(columns) != 11:
            print "Ignoring line:", columns
        else:
            table[columns[0]] = \
                { "Experiment1" : { "Expert" : columns[1] , "Time" : columns[2] }
                , "Experiment2a" : { "Expert" : figure10_2a(columns[3]) }
                , "Experiment2b" : { "Random" : figure10_2b_3b(columns[4]) }
                , "Experiment3a" : { "Expert" : figure10_3a(columns[5]) }
                , "Experiment3b" : { "Random" : figure10_2b_3b(columns[6]) }
                , "Experiment4" :
                      { "Leon" : { "1" : columns[7] , "2a" : columns[8] }
                      , "Synquid" : { "1" : columns[9] , "2a" : columns[10] }
                      }
                }
    return table

def figure10_2a(string):
    return string

def figure10_3a(string):
    if string == "FailedOverSpecialized":
        return "\\scriptsize{overspec}"
    else:
        return string

def figure10_2b_3b(string):
    if string == "---":
        return "---"
    if string == "RandFailedHigherOrder":
        return "---"
    elif string == "RandFailedNoNinety":
        return "\\scriptsize{failed}"
    elif string == "RandFailedTimeout":
        return "\\scriptsize{timeout}"
    else:
        triple = string[1:-1].split("|")
        if len(triple) == 3:
            [k50, k90, t] = triple
            if k90 == "":
                return showRand(k50, "$\\downarrow$", t)
            else:
                return showRand(k50, k90, t)
        else:
            return "XXX " + string

def showRand(k50, k90, t):
    return "(" + k50 + "," + k90 + ")$^{" + t + "}$"

figure10 = \
    loadFigure10()


################################################################################
## Load dictionaries of data for Figures 1 through TODO for artifact evaluation.

def data_loader(filename, expectedColumns, handleColumns):
    try:
        table = {}
        for line in open(filename):
            line = line.strip()
            columns = line.split(",")
            if len(columns) != expectedColumns:
                print "[" + filename + "] ignoring line:", columns
            else:
                handleColumns(table, columns)
        return table
    except IOError:
        print "[" + filename + "] not found"
        return None

def load_data_1(filename):
    def handleColumns(table, columns):
        [benchmark, time, expert, _, _, _] = columns
        benchmark = benchmark.replace(".elm", "")
        time = str(float(int(1000 * float(time))) / 1000).rjust(5, "0")
        table[benchmark] = { "Expert" : expert, "Time" : time }

    return data_loader(filename, 6, handleColumns)

# For Experiment 2a, extraExamples = 0.
# For Experiment 3a, extraExamples = 1 (base case is always required).
#
def load_data_2a_3a(filename, extraExamples):
    def handleColumns(table, columns):
        [benchmark, _, mythExamples, smythExamples, _, _] = columns
        benchmark = benchmark.replace(".elm", "")
        adjustedSmythExamples = extraExamples + float(smythExamples)
        pct = str(int(round(100 * adjustedSmythExamples / float(mythExamples))))
        if extraExamples == 0:
            string = smythExamples + " (" + pct + "%)"
        else:
            string = str(extraExamples) + "+" + smythExamples + " (" + pct + "%)"
        table[benchmark] = { "Expert" : string }

    return data_loader(filename, 6, handleColumns)

def load_data_2b_3b(filename):
    def handleColumns(table, columns):
        [benchmark, k50, k90] = columns
        table[benchmark] = { "Random" : showRand(k50, k90, "") }

    return data_loader(filename, 3, handleColumns)

def load_data_123(prefix):
    return \
        { "1" : load_data_1(prefix + "summaries/1.txt")
        , "2a" : load_data_2a_3a(prefix + "summaries/2a.txt", 0)
        , "2b" : load_data_2b_3b(prefix + "data/exp-2b/analysis.csv")
        , "3a" : load_data_2a_3a(prefix + "summaries/3a.txt", 1)
        , "3b" : load_data_2b_3b(prefix + "data/exp-3b/analysis.csv")
        }

ourData = \
    load_data_123("../../experiments/") # TODO

yourData = \
    load_data_123("../../experiments/TODO/") # TODO


################################################################################
## Write table data for Figures 1 through TODO for artifact evaluation.

output_tables = \
    { "1" : open("generated/figure-1-data.tex", "w+")
    , "2" : open("generated/figure-2-data.tex", "w+")
    , "3" : open("generated/figure-3-data.tex", "w+")
    }

def writeTables():
    for benchmarks in benchmarks_by_type:

        for i in output_tables:
            writeRow(output_tables[i], [])

        for benchmark in benchmarks:

            writeRowWithHighlights \
                ( output_tables["1"]
                , benchmark
                , ( figure10[benchmark]["Experiment1"]["Expert"]
                  , try_lookup(ourData["1"], benchmark, "Expert")
                  , try_lookup(yourData["1"], benchmark, "Expert")
                  )
                , ( figure10[benchmark]["Experiment1"]["Time"]
                  , try_lookup(ourData["1"], benchmark, "Time")
                  , try_lookup(yourData["1"], benchmark, "Time")
                  )
                )

            writeRowWithHighlights \
                ( output_tables["2"]
                , benchmark
                , ( figure10[benchmark]["Experiment2a"]["Expert"]
                  , try_lookup(ourData["2a"], benchmark, "Expert")
                  , try_lookup(yourData["2a"], benchmark, "Expert")
                  )
                , ( figure10[benchmark]["Experiment2b"]["Random"]
                  , try_lookup(ourData["2b"], benchmark, "Random")
                  , try_lookup(yourData["2b"], benchmark, "Random")
                  )
                )

            writeRowWithHighlights \
                ( output_tables["3"]
                , benchmark
                , ( figure10[benchmark]["Experiment3a"]["Expert"]
                  , try_lookup(ourData["3a"], benchmark, "Expert")
                  , try_lookup(yourData["3a"], benchmark, "Expert")
                  )
                , ( figure10[benchmark]["Experiment3b"]["Random"]
                  , try_lookup(ourData["3b"], benchmark, "Random")
                  , try_lookup(yourData["3b"], benchmark, "Random")
                  )
                )

def try_lookup(yourData, benchmark, column):
    try:
        return yourData[benchmark][column]
    except:
        return "$\\bullet$"

def escapeLaTeX(string):
    string = string.replace("_", "\\_")
    string = string.replace("%", "\\%")
    return string

def writeRow(f, list):
    f.write (escapeLaTeX
       ("&".join(list) + "\\\\ \n")
    )

def writeRowWithHighlights(f, name, triple1, triple2):
    f.write (escapeLaTeX
        ( name + "&"
        + "&".join(showThreeWithHighlights(triple1)) + "&"
        + "&".join(showThreeWithHighlights(triple2)) + "\\\\ \n"
        )
    )

def showThreeWithHighlights(triple):
    [s1, s2, s3] = triple
    out2 = s2 if s1 == s2 else "\\highlightBlue{" + s2 + "}"
    out3 = s3 if s2 == s3 else "\\highlightRed{" + s3 + "}"
    return [s1, out2, out3]

writeTables()
