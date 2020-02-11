#!/bin/sh

CONFIG_FILE=config.json

AUTO_LATEX=$(jq -r .auto_latex "$CONFIG_FILE")

if [ "$AUTO_LATEX" = true ]
then
    BODY_ONLY="t"
else
    BODY_ONLY="nil"
fi

emacs main.org \
    --batch \
    --eval \
    "(org-latex-export-to-latex nil nil nil "$BODY_ONLY")" --kill

if [ "$BODY_ONLY" = "nil" ]
then
    # add header.tex dependency
    sed -i '1 s/^/\\input{header.tex}\n\n/' main.tex

    sed -i '1 s/^/\\begin{document}\n\\maketitle\n/' main.tex

    echo -e "\n\\\end{document}" >> main.tex
fi

PDF_FILENAME=$(jq -r .pdf_filename "$CONFIG_FILE")
BUILD_DIR=build

latexmk -quiet -pdf -pdflatex="pdflatex -interaction=nonstopmode" main.tex # compile

mkdir $BUILD_DIR
mv main.pdf $BUILD_DIR/$PDF_FILENAME.pdf
mv main.fdb_latexmk main.fls main.log main.tex main.aux $BUILD_DIR
