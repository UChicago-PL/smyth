all:
	./latex-tables/make-tables.py
	pdflatex -output-directory=latex-tables latex-tables/smyth-experiment-tables.tex

clean: 
	rm -f latex-tables/*aux latex-tables/*out latex-tables/*log
