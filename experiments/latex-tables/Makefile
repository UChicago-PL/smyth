all:
	mkdir -p generated
	./make-tables.py
	pdflatex smyth-experiment-tables.tex

ours:
	cd ../exp-4-logic && make summary
	mkdir -p generated
	./make-tables.py
	pdflatex smyth-experiment-tables.tex
	cp smyth-experiment-tables.pdf smyth-experiment-tables-ours.pdf

icfp:
	./make-tables.py
	pdflatex smyth-experiment-tables.tex
	cp figure-10.tex $(SMYTH_PAPER)
	cp figure-10-data.tex $(SMYTH_PAPER)
	cp figure-10-stats.tex $(SMYTH_PAPER)
	cp figure-20.tex $(SMYTH_PAPER)
	cp figure-20-data.tex $(SMYTH_PAPER)
	cp ../author-results/data/exp-2b/png/*png $(SMYTH_PAPER)/random-graphs/2b/
	cp ../author-results/data/exp-3b/png/*png $(SMYTH_PAPER)/random-graphs/3b/
	cp ../author-results/data/exp-2b/histogram/*png $(SMYTH_PAPER)/random-graphs/2b/
	cp ../author-results/data/exp-3b/histogram/*png $(SMYTH_PAPER)/random-graphs/3b/

clean: 
	rm -f *aux *out *log
