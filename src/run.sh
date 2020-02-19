#!/bin/bash

CONFIG_FILE="config.json"

if [ -f "$CONFIG_FILE" ]
then
    AUTO_LATEX=$(jq -r .auto_latex ${CONFIG_FILE})
    # read pdf_filename or "main" if field is not present
    PDF_FILENAME=$(jq -r '[.pdf_filename // "main" ]|@tsv' ${CONFIG_FILE})
    SHELL_ESCAPE=$(jq -r .shell_escape ${CONFIG_FILE})
fi

if [ "$AUTO_LATEX" = true ]
then
    BODY_ONLY="nil"
else
    BODY_ONLY="t"
fi

EMACS_FILE="init.el"

if [ -f "$EMACS_FILE" ]
then
    EMACS_INIT="-l "$EMACS_FILE""
else
    EMACS_INIT=
fi

emacs main.org \
    --batch \
    ${EMACS_INIT} \
    --eval \
    "(org-latex-export-to-latex nil nil nil "$BODY_ONLY")" --kill

if [ "$BODY_ONLY" = "t" ]
then
    sed -i '1 s/^/\\input{header.tex}\n\n\\begin{document}\n/' main.tex

    echo -e "\n\\\end{document}" >> main.tex
fi

if [ -z "$PDF_FILENAME" ]
then
    PDF_FILENAME="main"
fi

if [ "$SHELL_ESCAPE" = true ]
then
    SHELL_ESCAPE="-shell-escape"
else
    SHELL_ESCAPE=""
fi

BUILD_DIR="build"

latexmk -quiet -pdf -pdflatex="pdflatex -interaction=nonstopmode" "$SHELL_ESCAPE" main.tex # compile

mkdir -p "$BUILD_DIR"
OUTPUT_PDF=""$BUILD_DIR"/"$PDF_FILENAME".pdf"
mv main.pdf "$OUTPUT_PDF"
mv main.fdb_latexmk main.fls main.log main.tex main.aux "$BUILD_DIR"
