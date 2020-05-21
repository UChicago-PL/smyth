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

clean: 
	rm -f *aux *out *log
