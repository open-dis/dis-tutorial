#!/bin/bash

mdFilesArray=( `cat "pandoc_MD_order.txt" `)
echo ${mdFilesArray[@]}

#pandoc -S -o tutorial.epub I_Introduction/DIS_Background.md I_Introduction/DIS_History.md I_Introduction/DIS_Examples.md

pandoc -S -o tutorial.epub ${mdFilesArray[@]} 
