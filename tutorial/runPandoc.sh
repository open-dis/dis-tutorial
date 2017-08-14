#!/bin/bash

# Reads a file that has an in-order list of .md files. 
# this list is provided to pandoc, which in effect
# concatenates them, and then uses the concatanated
# file to generate other formats. This includes epub,
# which is used in most ebooks, html, and pdf. 
#
# pandoc is at https://pandoc.org/
# Generated pdf requires LaTeX, available at https://www.latex-project.org/get/
# Example pandoc efforts: http://pandoc.org/demos.html
#
# No comments allowed in list of .md files, pandoc_MD_order.txt in this case.

 
MD_LIST_FILE="pandoc_MD_order.txt"


getArray() {
    array=() # Create array
    while IFS= read -r line # Read a line
    do
        array+=("$line") # Append line to the array
    done < "$1"
}
getArray ${MD_LIST_FILE}


echo full array is ${array[@]}



pandoc -S -o tutorial.epub ${array[@]} 
pandoc -S -o tutorial.html ${array[@]}
