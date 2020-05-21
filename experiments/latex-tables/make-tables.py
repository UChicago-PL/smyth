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

def data_loader(filename, expected_columns, handle_columns):
    try:
        table = {}
        for line in open(filename):
            line = line.strip()
            columns = line.split(",")
            if line.startswith("%"):
                print "[" + filename + "] ignoring line:", columns
            elif len(columns) != expected_columns:
                print "[" + filename + "] ignoring line:", columns
            else:
                handle_columns(table, columns)
        return table
    except IOError:
        print "[" + filename + "] not found"
        return None

def load_figure_10():
    def handle_columns(table, columns):
        table[columns[0]] = \
            { "Experiment1" : { "Expert" : columns[1] , "Time" : columns[2] }
            , "Experiment2a" : { "Expert" : figure_10_2a(columns[3]) }
            , "Experiment2b" : { "Random" : figure_10_2b_3b(columns[4]) }
            , "Experiment3a" : { "Expert" : figure_10_3a(columns[5]) }
            , "Experiment3b" : { "Random" : figure_10_2b_3b(columns[6]) }
            , "Experiment4" :
                  { "Leon" : { "1" : columns[7] , "2a" : columns[8] }
                  , "Synquid" : { "1" : columns[9] , "2a" : columns[10] }
                  }
            }

    return data_loader("figure-10-data.csv", 11, handle_columns)

def figure_10_2a(string):
    return string

def figure_10_3a(string):
    if string == "FailedOverSpecialized":
        return "\\scriptsize{overspec}"
    else:
        return string

def figure_10_2b_3b(string):
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
                return show_rand(k50, "$\\downarrow$", t)
            else:
                return show_rand(k50, k90, t)
        else:
            # Unexpected format
            return "XXX " + string

def show_rand(k50, k90, t):
    return "(" + k50 + "," + k90 + ")$^{" + t + "}$"

figure_10 = \
    load_figure_10()


################################################################################
## Load dictionaries of data for Tables 1 through 4 for artifact evaluation.

def load_data_1(filename):
    def handle_columns(table, columns):
        [benchmark, time, _, expert, _, _] = columns
        benchmark = benchmark.replace(".elm", "")
        time = str(float(int(1000 * float(time))) / 1000).ljust(5, "0")
        table[benchmark] = { "Expert" : expert, "Time" : time }

    return data_loader(filename, 6, handle_columns)

# For Experiment 2a, base_examples = 0.
# For Experiment 3a, base_examples = 1 (base case is always required).
#
def load_data_2a_3a(filename, base_examples):
    def handle_columns(table, columns):
        [benchmark, _, _, smyth_examples, _, _] = columns
        benchmark = benchmark.replace(".elm", "")
        myth_examples = figure_10[benchmark]["Experiment1"]["Expert"]
        adjusted_smyth_examples = base_examples + float(smyth_examples)
        pct = str(int(round(100 * adjusted_smyth_examples / float(myth_examples))))
        if base_examples == 0:
            string = smyth_examples + " (" + pct + "%)"
        else:
            string = str(base_examples) + "+" + smyth_examples + " (" + pct + "%)"
        table[benchmark] = { "Expert" : string }

    return data_loader(filename, 6, handle_columns)

def load_data_2b_3b(filename):
    def handle_columns(table, columns):
        [benchmark, k50, k90] = columns
        table[benchmark] = { "Random" : show_rand(k50, k90, "") }

    return data_loader(filename, 3, handle_columns)

def load_data_4(filename):
    def handle_columns(table, columns):
        [benchmark, result] = columns
        table[benchmark] = { "Result" : result }

    return data_loader(filename, 2, handle_columns)

def load_data_123(prefix):
    return \
        { "1" : load_data_1(prefix + "summaries/1.txt")
        , "2a" : load_data_2a_3a(prefix + "summaries/2a.txt", 0)
        , "2b" : load_data_2b_3b(prefix + "data/exp-2b/analysis.csv")
        , "3a" : load_data_2a_3a(prefix + "summaries/3a.txt", 1)
        , "3b" : load_data_2b_3b(prefix + "data/exp-3b/analysis.csv")
        }

our_data = \
    load_data_123("../author-results/")

your_data = \
    load_data_123("../")

data_4_prefix = "../exp-4-logic/results/summaries/"
data_4 = \
    { "Leon1" : load_data_4(data_4_prefix + "exp-4-leon-1.csv")
    , "Leon2a" : load_data_4(data_4_prefix + "exp-4-leon-2a.csv")
    , "Synquid1" : load_data_4(data_4_prefix + "exp-4-synquid-1.csv")
    , "Synquid2a" : load_data_4(data_4_prefix + "exp-4-synquid-2a.csv")
    }


################################################################################
## Write table data for Tables 1 through 4 for artifact evaluation.

output_tables = \
    { "1" : open("generated/table-1-data.tex", "w+")
    , "2" : open("generated/table-2-data.tex", "w+")
    , "3" : open("generated/table-3-data.tex", "w+")
    , "4" : open("generated/table-4-data.tex", "w+")
    }

def write_tables():
    for benchmarks in benchmarks_by_type:

        for i in output_tables:
            output_tables[i].write("\\\\\n")

        for benchmark in benchmarks:

            write_row_123 \
                ( output_tables["1"]
                , benchmark
                , ( figure_10[benchmark]["Experiment1"]["Expert"]
                  , try_lookup_123(our_data["1"], benchmark, "Expert")
                  , try_lookup_123(your_data["1"], benchmark, "Expert")
                  )
                , ( figure_10[benchmark]["Experiment1"]["Time"]
                  , try_lookup_123(our_data["1"], benchmark, "Time")
                  , try_lookup_123(your_data["1"], benchmark, "Time")
                  )
                )

            write_row_123 \
                ( output_tables["2"]
                , benchmark
                , ( figure_10[benchmark]["Experiment2a"]["Expert"]
                  , try_lookup_123(our_data["2a"], benchmark, "Expert")
                  , try_lookup_123(your_data["2a"], benchmark, "Expert")
                  )
                , ( figure_10[benchmark]["Experiment2b"]["Random"]
                  , try_lookup_123(our_data["2b"], benchmark, "Random")
                  , try_lookup_123(your_data["2b"], benchmark, "Random")
                  )
                )

            write_row_123 \
                ( output_tables["3"]
                , benchmark
                , ( figure_10[benchmark]["Experiment3a"]["Expert"]
                  , try_lookup_123(our_data["3a"], benchmark, "Expert")
                  , try_lookup_123(your_data["3a"], benchmark, "Expert")
                  )
                , ( figure_10[benchmark]["Experiment3b"]["Random"]
                  , try_lookup_123(our_data["3b"], benchmark, "Random")
                  , try_lookup_123(your_data["3b"], benchmark, "Random")
                  )
                )

            write_row_4 \
                ( output_tables["4"]
                , benchmark
                , ( figure_10[benchmark]["Experiment4"]["Leon"]["1"]
                  , try_lookup_4(data_4["Leon1"], benchmark, "Result")
                  )
                , ( figure_10[benchmark]["Experiment4"]["Leon"]["2a"]
                  , try_lookup_4(data_4["Leon2a"], benchmark, "Result")
                  )
                , ( figure_10[benchmark]["Experiment4"]["Synquid"]["1"]
                  , try_lookup_4(data_4["Synquid1"], benchmark, "Result")
                  )
                , ( figure_10[benchmark]["Experiment4"]["Synquid"]["2a"]
                  , try_lookup_4(data_4["Synquid2a"], benchmark, "Result")
                  )
                )

def make_try_lookup(default):
    def try_lookup(table, benchmark, column):
        try:
            return table[benchmark][column]
        except:
            return default
    return try_lookup

try_lookup_123 = \
    make_try_lookup("$\\bullet$")

try_lookup_4 = \
    make_try_lookup("X")

def escape_LaTeX(string):
    string = string.replace("_", "\\_")
    string = string.replace("%", "\\%")
    return string

def write_row_123(f, name, triple1, triple2):
    def show(triple):
        [s1, s2, s3] = triple
        out2 = s2 if s1 == s2 else "\\highlightBlue{" + s2 + "}"
        out3 = s3 if s2 == s3 else "\\highlightRed{" + s3 + "}"
        return [s1, out2, out3]

    f.write (escape_LaTeX
        ( name + "&"
        + "&".join(show(triple1)) + "&"
        + "&".join(show(triple2)) + "\\\\\n"
        )
    )

def write_row_4(f, name, pair1, pair2, pair3, pair4):
    def show(pair):
        [s1, s2] = pair
        if s1 == s2:
            return [s1]
        ## NOTE: higher-order functions not in exp-4-logic/
        elif name in ["list_filter", "list_map", "list_fold", "tree_map"] and \
             s2 == "X":
            return [s1]
        else:
            # out2 = "\\highlightBlue{" + s2 + "}"
            # return [s1, out2]
            return [s1, "\\highlightBlue{$\\Rightarrow$}", s2]

    f.write (escape_LaTeX
        ( name + "&"
        + " ".join(show(pair1)) + "&"
        + " ".join(show(pair2)) + "&"
        + " ".join(show(pair3)) + "&"
        + " ".join(show(pair4)) + "\\\\\n"
        )
    )

write_tables()
