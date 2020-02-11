#!/bin/sh

# t enables body-only option
emacs main.org \
    --batch \
    --eval \
    "(org-latex-export-to-latex nil nil nil t)" --kill

# add header.tex dependency
sed -i '1 s/^/\\input{header.tex}\n\n/' main.tex
sed -i '1 s/^/\\begin{document}\n\\maketitle\n/' main.tex

echo -e "\n\\\end{document}" >> main.tex

PDF_FILENAME=$(jq -r .pdf_filename config.json)
BUILD_DIR=build

latexmk -quiet -pdf -pdflatex="pdflatex -interaction=nonstopmode" main.tex # compile

mkdir $BUILD_DIR
mv main.pdf $BUILD_DIR/$PDF_FILENAME.pdf
mv main.fdb_latexmk main.fls main.log main.tex main.aux $BUILD_DIR
