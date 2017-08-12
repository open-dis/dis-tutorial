#!/bin/bash

# Reads a file that has an in-order list of .md files. 
# this list is provided to pandoc, which in effect
# concatenates them, and then uses the concatenated
# file to generate other formats. This includes epub,
# which is used in most ebooks, html, and pdf. 
#
# pandoc is at https://pandoc.org/
# Generated pdf requires LaTeX, available at https://www.latex-project.org/get/
# Example pandoc efforts: http://pandoc.org/demos.html

mdFilesArray=( `cat "pandoc_MD_order.txt" `)
echo ${mdFilesArray[@]}

pandoc -S -o tutorial.epub ${mdFilesArray[@]} 
pandoc -S -o tutorial.html ${mdFilesArray[@]}
