#!/bin/sh

for image in ./sprites/*.png
do
	# Trim the useless empty space around the pokemon.
	convert -trim "$image" "$image"
done
