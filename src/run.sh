#!/bin/sh

emacs \
    --batch \
    -l ~/.emacs.d/init.el \
    main.org -f org-latex-export-to-latex --kill

PDF_FILENAME=$(jq -r .pdf_filename config.json)
BUILD_DIR=build

latexmk -quiet -pdf -pdflatex="pdflatex -interaction=nonstopmode" main.tex # compile

mkdir $BUILD_DIR
mv main.pdf $BUILD_DIR/$PDF_FILENAME.pdf
mv main.fdb_latexmk main.fls main.log main.tex main.aux $BUILD_DIR
