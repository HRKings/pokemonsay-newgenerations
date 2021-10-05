#!/bin/sh

#
# This script clones and formats the sprites from PokeSprite project
#

# Clone the PokeSprite Repos
git clone git@github.com:msikma/pokesprite.git

POKEMON_JSON=$(jq --compact-output '.[] | { id: .idx, slug: .slug.eng }' < ./pokesprite/data/pokemon.json)

mkdir -p 'sprites'

for row in $POKEMON_JSON; do
	SLUG=$(echo "$row" | jq --raw-output '.slug')
	DEX_NUMBER=$(echo "$row" | jq --raw-output '.id')

	REGULAR_SPRITES=$(find ./pokesprite/pokemon-gen8/regular -maxdepth 1 -type f -name "${SLUG}*")
	SHINY_SPRITE=$(find ./pokesprite/pokemon-gen8/shiny -maxdepth 1 -type f -name "${SLUG}*")

	FEMALE_REGULAR=$(find ./pokesprite/pokemon-gen8/regular/female -maxdepth 1 -type f -name "${SLUG}*")
	FEMALE_SHINY=$(find ./pokesprite/pokemon-gen8/regular/female -maxdepth 1 -type f -name "${SLUG}*")

	for regularSprite in $REGULAR_SPRITES; do
		cp "$regularSprite" "./sprites/${DEX_NUMBER}_$(basename "$regularSprite")"
	done

	for shinySprite in $SHINY_SPRITE; do
		cp "$shinySprite" "./sprites/S_${DEX_NUMBER}_$(basename "$shinySprite")"
	done

	for femaleSprite in $FEMALE_REGULAR; do
		cp "$femaleSprite" "./sprites/F_${DEX_NUMBER}_$(basename "$femaleSprite")"
	done

	for femaleShiny in $FEMALE_SHINY; do
		cp "$femaleShiny" "./sprites/FS_${DEX_NUMBER}_$(basename "$femaleShiny")"
	done
done