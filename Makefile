PAPERS = thermodynamics_onsager_I thermodynamics_onsager_II
FILENAME ?= thermodynamics_onsager_I
TEMPLATE = my_template.tex
PDFENGINE = pdflatex
LATEX_FLAGS = -interaction=nonstopmode
PANDOC_LATEX_FLAGS = --from=markdown+tex_math_single_backslash+tex_math_dollars+raw_tex --to=latex --standalone --template=$(TEMPLATE) --biblatex
PANDOC_DOC_FLAGS = --from=markdown+tex_math_single_backslash+tex_math_dollars

TEX_FILES = $(addsuffix .tex,$(PAPERS))
PDF_FILES = $(addsuffix .pdf,$(PAPERS))

.PHONY: all latex pdf paper1 paper2 figures html epub docx odt clean view

all: pdf

latex: $(TEX_FILES)

pdf: $(PDF_FILES)

paper1: thermodynamics_onsager_I.pdf

paper2: thermodynamics_onsager_II.pdf

%.tex: %.md $(TEMPLATE)
	pandoc $< $(PANDOC_LATEX_FLAGS) --output=$@

%.pdf: %.tex
	$(PDFENGINE) $(LATEX_FLAGS) $<
	biber $(basename $<)
	$(PDFENGINE) $(LATEX_FLAGS) $<
	$(PDFENGINE) $(LATEX_FLAGS) $<

figures:
	julia --project=. -e "include(\"thermodynamics_onsager.jl\"); plot_ecosystem_comparison(); plot_energy_cascade()"

html:
	pandoc $(FILENAME).md $(PANDOC_DOC_FLAGS) --to=html5 --output=$(FILENAME).html --mathjax --embed-resources --standalone

epub:
	pandoc $(FILENAME).md $(PANDOC_DOC_FLAGS) --to=epub --output=$(FILENAME).epub --toc

docx:
	pandoc $(FILENAME).md $(PANDOC_DOC_FLAGS) --to=docx --output=$(FILENAME).docx

odt:
	pandoc $(FILENAME).md $(PANDOC_DOC_FLAGS) --to=odt --output=$(FILENAME).odt

ifeq ($(OS),Windows_NT)
view:
	cmd /C start "" $(FILENAME).pdf

clean:
	powershell -NoProfile -Command "Remove-Item -Force -ErrorAction SilentlyContinue *.aux, *.bbl, *.bcf, *.blg, *.log, *.out, *.run.xml, *.spl, *.toc, *.lof, *.lot, *.fls, *.fdb_latexmk"
else
view:
	zathura $(FILENAME).pdf

clean:
	rm -f *.aux *.bbl *.bcf *.blg *.log *.out *.run.xml *.spl *.toc *.lof *.lot *.fls *.fdb_latexmk
endif
