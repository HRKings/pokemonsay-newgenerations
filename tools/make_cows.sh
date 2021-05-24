#!/bin/sh

#
# Transform image files pixel per pixel into cow files.
#

for FULLFILENAME in ./scrapped-data/*.png
do
    FILENAME=$(basename "$FULLFILENAME")
    FILENAME="${FILENAME%.*}"
    img2xterm --cow "$FULLFILENAME" "../pokemons/$FILENAME.cow"
done
