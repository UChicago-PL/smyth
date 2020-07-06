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
## Load dictionaries of data for Figure 10 and Figure 20.

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
def load_data_2a_3a(data_1, filename, base_examples):
    def handle_columns(table, columns):
        [benchmark, _, _, smyth_examples, _, _] = columns
        benchmark = benchmark.replace(".elm", "")
        myth_examples = data_1[benchmark]["Expert"]
        adjusted_smyth_examples = base_examples + float(smyth_examples)
        pct = str(int(round(100 * adjusted_smyth_examples / float(myth_examples))))
        if base_examples == 0:
            string = smyth_examples + " (" + pct + "%)"
        else:
            string = str(base_examples) + "+" + smyth_examples + " (" + pct + "%)"
        table[benchmark] = { "Expert" : string }

    return data_loader(filename, 6, handle_columns)

def load_data_2b_3b(filename):
    def show_random(k50, k90, t):
        if k50 == "---" and k90 == "---":
            return "\\labelRandomFailed"
        elif k90 == "---":
          return "\\labelColorFailed{(" + k50 + ",$\\downarrow$)$^{" + t + "}$}"
        else:
          return "(" + k50 + "," + k90 + ")$^{" + t + "}$"

    def handle_columns(table, columns):
        [benchmark, k50, k90] = columns
        table[benchmark] = { "Random" : show_random(k50, k90, "") }

    return data_loader(filename, 3, handle_columns)

def load_data_4(filename):
    def handle_columns(table, columns):
        [benchmark, result] = columns
        table[benchmark] = { "Result" : result }

    return data_loader(filename, 2, handle_columns)

def load_data_5a(data_2a, filename): # Copy-paste with load_data_2a_3a
    def handle_columns(table, columns):
        [benchmark, _, _, smyth_poly_examples, _, _] = columns
        benchmark = benchmark.replace(".elm", "")
        try:
            # quick-and-dirty: undo load_data_2a_3a
            smyth_mono_examples = data_2a[benchmark]["Expert"].split(" ")[0]
            pct = str(int(round(100 * float(smyth_poly_examples) / float(smyth_mono_examples))))
            string = smyth_poly_examples + " (" + pct + "%)"
            table[benchmark] = { "Expert" : string }
        except:
            table[benchmark] = { "Expert" : str(smyth_poly_examples) + " (---)" }

    return data_loader(filename, 6, handle_columns)

def load_data_6a(data_3a, filename): # Copy-paste with load_data_2a_3a
    def handle_columns(table, columns):
        [benchmark, _, _, smyth_poly_examples, _, _] = columns
        benchmark = benchmark.replace(".elm", "")
        try:
            # quick-and-dirty: undo load_data_2a_3a
            smyth_mono_examples = data_3a[benchmark]["Expert"].split(" ")[0].split("+")[1]
            pct = str(int(round(100 * (1 + float(smyth_poly_examples))) / float(1 + float(smyth_mono_examples))))
            string = "1+" + smyth_poly_examples + " (" + pct + "%)"
            table[benchmark] = { "Expert" : string }
        except:
            string = "1+" + smyth_poly_examples + " (---)"
            table[benchmark] = { "Expert" : string }

    return data_loader(filename, 6, handle_columns)

def load_data_123(prefix):
    data_1 = load_data_1(prefix + "summaries/1.txt")
    return \
        { "1" : data_1
        , "2a" : load_data_2a_3a(data_1, prefix + "summaries/2a.txt", 0)
        , "2b" : load_data_2b_3b(prefix + "data/exp-2b/analysis.csv")
        , "3a" : load_data_2a_3a(data_1, prefix + "summaries/3a.txt", 1)
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

our_data["5a"] = \
    load_data_5a(our_data["2a"], "../author-results/summaries/5a.txt")

our_data["6a"] = \
    load_data_6a(our_data["3a"], "../author-results/summaries/6a.txt")

our_data["5b"] = \
    load_data_2b_3b("../author-results/data/exp-5b/analysis.csv")

our_data["6b"] = \
    load_data_2b_3b("../author-results/data/exp-6b/analysis.csv")


################################################################################
## Present Figure 10 and Figure 10 data with colors and labels where needed.

benchmarks_1_timeout = \
    [ "list_compress", "tree_binsert", "tree_nodes_at_level", "tree_postorder" ]

benchmarks_1_overspec = \
    [ "list_even_parity" ]

benchmarks_1_failed = \
    benchmarks_1_timeout + benchmarks_1_overspec

benchmarks_2b_timeout = \
    [ "list_pairwise_swap", "list_sorted_insert", "tree_count_leaves" ]

benchmarks_3b_timeout = \
    [ "list_pairwise_swap", "list_sorted_insert", "tree_count_leaves" ]

benchmarks_higher_order = \
    [ "list_filter", "list_fold", "list_map", "tree_map" ]

benchmarks_non_recursive = \
    [ "bool_band", "bool_bor", "bool_impl", "bool_neg", "bool_xor"
    , "list_hd", "list_inc", "list_rev_fold", "list_sum", "list_tl"
    , "nat_pred"
    ]

benchmarks_1_2_same_examples = \
    [ "bool_neg", "bool_xor", "list_length", "nat_max" ]

benchmarks_5_6_not_poly = \
    [ "bool_band", "bool_bor", "bool_impl", "bool_neg", "bool_xor"
    , "list_hd", "list_inc", "list_nth", "list_sort_sorted_insert", "list_sorted_insert", "list_sum"
    , "nat_add", "nat_iseven", "nat_max", "nat_pred"
    ]

benchmarks_5_6_failed = \
    [ "list_pairwise_swap" ]

benchmarks_5b_timeout = \
    [ "tree_count_leaves" ]

benchmarks_6b_timeout = \
    [ "tree_count_leaves" ]

def show_1_expert(benchmark):
    if benchmark == "list_compress": return "13"
    elif benchmark == "list_even_parity": return "7"
    elif benchmark == "tree_binsert": return "20"
    elif benchmark == "tree_nodes_at_level": return "11"
    elif benchmark == "tree_postorder": return "20"
    else:
        try:
            string = our_data["1"][benchmark]["Expert"]
            if benchmark == "list_filter":
                return "\\phantom{*}" + string + "*"
            else:
                return  string
        except KeyError:
            return "XXX"

def show_1_time(benchmark):
    try:
        return our_data["1"][benchmark]["Time"]
    except KeyError:
        if benchmark in benchmarks_1_timeout: return "\\labelTimeout"
        elif benchmark in benchmarks_1_overspec: return "\\labelOverspec"
        else: return "XXX"

def show_2a(benchmark):
    try:
        return our_data["2a"][benchmark]["Expert"]
    except KeyError:
        if benchmark in benchmarks_1_failed: return "\\labelBlankOneFailed"
        else: return "XXX"

def show_2b(benchmark):
    try:
        string = our_data["2b"][benchmark]["Random"]
        ## These special case timeouts c/should be read from
        ## ../author-results/data/exp-2b/csv/*csv
        if benchmark in ["tree_collect_leaves", "tree_preorder"]:
            return string + "$^{\\labelRandomTime{3}}$"
        elif benchmark == "tree_count_nodes":
            return string + "$^{\\labelRandomTime{10}}$"
        else:
            return string
    except KeyError:
        if benchmark in benchmarks_1_failed: return "\\labelBlankOneFailed"
        elif benchmark in benchmarks_higher_order: return "\\labelBlankHigherOrder"
        elif benchmark in benchmarks_2b_timeout: return "\\labelTimeout"
        else: return "XXX"

def show_3a(benchmark):
    try:
        return our_data["3a"][benchmark]["Expert"]
    except KeyError:
        if benchmark in benchmarks_1_failed: return "\\labelBlankOneFailed"
        elif benchmark in benchmarks_non_recursive: return "\\labelBlankNonRec"
        elif benchmark == "list_concat": return "\\labelIncorrect"
        elif benchmark == "list_pairwise_swap": return "\\labelOverspec"
        else: return "XXX"

def show_3b(benchmark):
    try:
        string = our_data["3b"][benchmark]["Random"]
        ## These special case timeouts c/should be read from
        ## ../author-results/data/exp-3b/csv/*csv
        if benchmark == "tree_count_nodes":
            return string + "$^{\\labelRandomTime{3}}$"
        else:
            return string
    except KeyError:
        if benchmark in benchmarks_1_failed: return "\\labelBlankOneFailed"
        elif benchmark in benchmarks_higher_order: return "\\labelBlankHigherOrder"
        elif benchmark in benchmarks_2b_timeout: return "\\labelTimeout"
        elif benchmark in benchmarks_non_recursive: return "\\labelBlankNonRec"
        else: return "XXX"

def show_4(tool, experiment, benchmark):
    try:
        if benchmark in benchmarks_1_failed:
            return "\\labelBlankOneFailed"
        elif benchmark in benchmarks_1_2_same_examples and experiment == "2a":
            return "\\labelBlankSameExpertExamples"
        elif benchmark in benchmarks_higher_order:
            return "\\leonquidHigherOrderFunc"
        else:
            return data_4[tool + experiment][benchmark]["Result"]
    except KeyError:
        return "XXX"

def show_5a(benchmark):
    try:
        return our_data["5a"][benchmark]["Expert"]
    except KeyError:
        if benchmark in benchmarks_1_failed: return "\\labelBlankOneFailed"
        elif benchmark in benchmarks_5_6_not_poly: return "\\labelColorSkipped{---}"
        elif benchmark in benchmarks_5_6_failed: return "\\labelColorFailed{\\scriptsize{failed}}"
        else: return "XXX"

def show_5b(benchmark):
    try:
        string = our_data["5b"][benchmark]["Random"]
        ## These special case timeouts c/should be read from
        ## ../author-results/data/exp-5b/csv/*csv
        if benchmark in ["tree_collect_leaves", "tree_preorder"]:
            return string + "$^{\\labelRandomTime{3}}$"
        elif benchmark == "tree_count_nodes":
            return string + "$^{\\labelRandomTime{10}}$"
        else:
            return string
    except KeyError:
        if benchmark in benchmarks_1_failed: return "\\labelBlankOneFailed"
        elif benchmark in benchmarks_higher_order: return "\\labelBlankHigherOrder"
        elif benchmark in benchmarks_5_6_not_poly: return "\\labelColorSkipped{---}"
        elif benchmark in benchmarks_5_6_failed: return "\\labelColorFailed{\\scriptsize{failed}}"
        elif benchmark in benchmarks_5b_timeout : return "\\labelTimeout"
        else: return "XXX"

def show_6a(benchmark):
    try:
        return our_data["6a"][benchmark]["Expert"]
    except KeyError:
        if benchmark in benchmarks_1_failed: return "\\labelBlankOneFailed"
        elif benchmark in benchmarks_non_recursive: return "\\labelBlankNonRec"
        elif benchmark in benchmarks_5_6_not_poly: return "\\labelColorSkipped{---}"
        elif benchmark in benchmarks_5_6_failed: return "\\labelColorFailed{\\scriptsize{failed}}"
        else: return "XXX"

def show_6b(benchmark):
    try:
        string = our_data["6b"][benchmark]["Random"]
        ## These special case timeouts c/should be read from
        ## ../author-results/data/exp-6b/csv/*csv
        if benchmark == "tree_count_nodes":
            return string + "$^{\\labelRandomTime{3}}$"
        else:
            return string
    except KeyError:
        if benchmark in benchmarks_1_failed: return "\\labelBlankOneFailed"
        elif benchmark in benchmarks_higher_order: return "\\labelBlankHigherOrder"
        elif benchmark in benchmarks_non_recursive: return "\\labelBlankNonRec"
        elif benchmark in benchmarks_5_6_not_poly: return "\\labelColorSkipped{---}"
        elif benchmark in benchmarks_5_6_failed: return "\\labelColorFailed{\\scriptsize{failed}}"
        elif benchmark in benchmarks_6b_timeout : return "\\labelTimeout"
        else: return "XXX"


################################################################################
## Write table data for Figure 10, Tables 1 through 3, and Figure 20.

output_tables = \
    { "1" : open("generated/table-1-data.tex", "w+")
    , "2" : open("generated/table-2-data.tex", "w+")
    , "3" : open("generated/table-3-data.tex", "w+")
    }

output_figure_10_data = \
    open("figure-10-data.tex", "w+")

output_figure_20_data = \
    open("figure-20-data.tex", "w+")

def write_tables():
    for benchmarks in benchmarks_by_type:

        output_figure_10_data.write("&&&&&&&&&&\\\\\n")
        output_figure_20_data.write("&&&&\\\\\n")

        for i in output_tables:
            output_tables[i].write("\\\\\n")

        for benchmark in benchmarks:

            write_figure_10_20_row \
                ( output_figure_10_data
                , [ benchmark
                  , show_1_expert(benchmark)
                  , show_1_time(benchmark)
                  , show_2a(benchmark)
                  , show_2b(benchmark)
                  , show_3a(benchmark)
                  , show_3b(benchmark)
                  , show_4("Leon", "1", benchmark)
                  , show_4("Leon", "2a", benchmark)
                  , show_4("Synquid", "1", benchmark)
                  , show_4("Synquid", "2a", benchmark)
                  ]
                )

            write_row_123 \
                ( output_tables["1"]
                , benchmark
                , ( show_1_expert(benchmark)
                  , try_lookup_123(our_data["1"], benchmark, "Expert")
                  , try_lookup_123(your_data["1"], benchmark, "Expert")
                  )
                , ( show_1_time(benchmark)
                  , try_lookup_123(our_data["1"], benchmark, "Time")
                  , try_lookup_123(your_data["1"], benchmark, "Time")
                  )
                )

            write_row_123 \
                ( output_tables["2"]
                , benchmark
                , ( show_2a(benchmark)
                  , try_lookup_123(our_data["2a"], benchmark, "Expert")
                  , try_lookup_123(your_data["2a"], benchmark, "Expert")
                  )
                , ( show_2b(benchmark)
                  , try_lookup_123(our_data["2b"], benchmark, "Random")
                  , try_lookup_123(your_data["2b"], benchmark, "Random")
                  )
                )

            write_row_123 \
                ( output_tables["3"]
                , benchmark
                , ( show_3a(benchmark)
                  , try_lookup_123(our_data["3a"], benchmark, "Expert")
                  , try_lookup_123(your_data["3a"], benchmark, "Expert")
                  )
                , ( show_3b(benchmark)
                  , try_lookup_123(our_data["3b"], benchmark, "Random")
                  , try_lookup_123(your_data["3b"], benchmark, "Random")
                  )
                )

            if benchmark in benchmarks_1_failed:
                pass
            elif benchmark in benchmarks_5_6_not_poly:
                pass
            else:
                write_figure_10_20_row \
                    ( output_figure_20_data
                    , [ benchmark
                      , show_5a(benchmark)
                      , show_5b(benchmark)
                      , show_6a(benchmark)
                      , show_6b(benchmark)
                      ]
                    )

    output_figure_10_data.write("&&&&&&&&&&\\\\\n")
    output_figure_20_data.write("&&&&\\\\\n")

def make_try_lookup(default):
    def try_lookup(table, benchmark, column):
        try:
            return table[benchmark][column]
        except:
            return default
    return try_lookup

try_lookup_123 = \
    make_try_lookup("$\\bullet$")

def escape_LaTeX(string):
    string = string.replace("_", "\\_")
    string = string.replace("%", "\\%")
    return string

def write_figure_10_20_row(f, columns):
    f.write (escape_LaTeX( "&".join(columns) + "\\\\\n"))

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

write_tables()


################################################################################
## Compute 2a and 3a stats.

def get_pct(string):
    # Quick-and-dirty undo stringification of load_data_2a_3a
    string = string.split(" ")[1]
    string = string[1:-1]
    string = string[:-1]
    pct = int(string)
    return pct

def get_sketch_examples(string):
    # Quick-and-dirty undo stringification of load_data_2a_3a
    string = string.split(" ")[0]
    string = string.split("+")[1]
    num = int(string)
    return num

def avg(i, j):
    return float(i) / float(j)

def compute_2a_stats():
    succeeded = 0
    failed = 0
    total_pct = 0

    for benchmarks in benchmarks_by_type:
        for benchmark in benchmarks:
            try:
                pct = get_pct(our_data["2a"][benchmark]["Expert"])
                total_pct += pct
                succeeded += 1
            except KeyError:
                failed += 1

    print ""
    print "Succeeded:", succeeded
    print "Average:", avg(total_pct, succeeded), "%"
    print "Average Upper Bound:", avg(total_pct + 100*failed, succeeded + failed), "%"

def compute_3a_stats():
    succeeded = 0
    failed = 0
    total_pct = 0
    total_pct_2a = 0
    max_examples = 0
    total_examples = 0

    for benchmarks in benchmarks_by_type:
        for benchmark in benchmarks:
            try:
                ex = get_sketch_examples(our_data["3a"][benchmark]["Expert"])
                pct = get_pct(our_data["3a"][benchmark]["Expert"])
                pct_2a = get_pct(our_data["2a"][benchmark]["Expert"])
                total_examples += ex
                if ex > max_examples:
                    max_examples = ex
                total_pct += pct
                total_pct_2a += pct_2a
                succeeded += 1
            except KeyError:
                failed += 1

    print ""
    print "Succeeded:", succeeded
    print "Average:", avg(total_pct, succeeded), "%"
    print "Average of these from 2a:", avg(total_pct_2a, succeeded), "%"
    print "Max Examples:", max_examples
    print "Average Examples:", avg(total_examples, succeeded)

compute_2a_stats()
compute_3a_stats()
