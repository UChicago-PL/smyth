all:
	cd ../exp-4-logic && make summary
	mkdir -p generated
	./make-tables.py
	pdflatex smyth-experiment-tables.tex

clean: 
	rm -f *aux *out *log
