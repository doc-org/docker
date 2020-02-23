#!/bin/bash

config_file="config.json"

if [ -f "$config_file" ]
then
    auto_latex=$(jq -r .auto_latex ${config_file})
    # read pdf_filename or "main" if field is not present
    pdf_filename=$(jq -r '[.pdf_filename // "main" ]|@tsv' ${config_file})
    shell_escape=$(jq -r .shell_escape ${config_file})
fi

if [ "$auto_latex" = true ]
then
    body_only="nil"
else
    body_only="t"
fi

emacs_file="init.el"

if [ -f "$emacs_file" ]
then
    emacs_init="-l "$emacs_file""
else
    emacs_init=
fi

emacs main.org \
    --batch \
    ${emacs_init} \
    --eval \
    "(org-latex-export-to-latex nil nil nil "$body_only")" --kill

if [ "$body_only" = "t" ]
then
    sed -i '1 s/^/\\input{header.tex}\n\n\\begin{document}\n/' main.tex

    echo -e "\n\\\end{document}" >> main.tex
fi

if [ -z "$pdf_filename" ]
then
    pdf_filename="main"
fi

if [ "$shell_escape" = true ]
then
    shell_escape="-shell-escape"
else
    shell_escape=""
fi

build_dir="build"

latexmk -quiet -pdf -pdflatex="pdflatex -interaction=nonstopmode" "$shell_escape" main.tex # compile

mkdir -p "$build_dir"
output_pdf=""$build_dir"/"$pdf_filename".pdf"
mv main.pdf "$output_pdf"
mv main.fdb_latexmk main.fls main.log main.tex main.aux "$build_dir"
