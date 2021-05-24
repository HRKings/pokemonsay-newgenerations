#!/bin/sh

#
# This script scraps some pokémon pictures from Bulbapedia.
#

BULBAPEDIA_PAGE_URL="http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_National_Pok%C3%A9dex_number"
BULBAPEDIA_PAGE_NAME="bulbapedia.html"
SCRAP_FOLDER="`pwd`/scrapped-data"

# Make sure the directory for the scrapped data is there.
mkdir -p "${SCRAP_FOLDER}"

# Download the bulbapedia page if it doesn't already.
if [ ! -e "scrapped-data/bulbapedia.html" ]; then
	echo "  > Downloading '$BULBAPEDIA_PAGE_URL' to '$SCRAP_FOLDER/$BULBAPEDIA_PAGE_NAME' ..."
	wget "$BULBAPEDIA_PAGE_URL" -O "$SCRAP_FOLDER/$BULBAPEDIA_PAGE_NAME" -q
	echo "  > Downloaded."
fi

# Dear furure me,
#
#   If you are in need to maintain this part of the code... I am
# realy sorry for you (T.T). This was the best I could do... But
# I will try to explain things here a little bit.
#   'cat' will read the file and pipe its output to 'sed'. 'sed'
# will filter the html searching for the Pokémon name and its
# image url. 'sed' will output the Pokémons in this format:
# "<POKEMON_NAME>=<POKEMON_URL>". And the output of 'sed' will be
# stored in a variable we will use later.
#   Then, the content of the variable will be read one line at a
# time in the for loop. Within the for loop, I extract the pokemon
# name and the url from the read line. And then, it just downloads
# the content of the url to a file.
#   Again... I'm sorry for all the trouble. But I hope you will
# grow stronger and may be able to turn this code into something
# more readable.
#
#                                                     Kind regards,
#                                           Yourself from the past.

POKEMON_IMAGES=$(
	cat "${SCRAP_FOLDER}/${BULBAPEDIA_PAGE_NAME}" | \
	sed -nr 's;^.*<img alt="(.*)" src="(//cdn2.bulbagarden.net/upload/.*\.png)".*/>.*$;\1=\2;p' \
)

echo "$POKEMON_IMAGES" | while read line
do
	POKEMON_NAME="${line%=*}"
	POKEMON_URL="https:${line#*=}"
	POKEMON_FORM=$(echo ${POKEMON_URL}| sed -nr 's;.*/[0-9]+([A-Z]+)MS.*;\1;p')
	POKEMON_NATIONAL_DEX_NUMBER=$(echo ${POKEMON_URL}| sed -nr 's;.*/([0-9]+).*;\1;p')

	# Unescape HTML characters... Damn "Farfetch&#39;d".
	POKEMON_NAME=$(echo "${POKEMON_NAME}" | sed "s/&#39;/'/")

	if [ -n "${POKEMON_FORM}" ]
	then
    	POKEMON_NAME="${POKEMON_NAME}-${POKEMON_FORM}"
	fi

	# If wget is interrupted by a SIGINT or something, it will
	# leave a broken file. Let's remove it and exit in case we
	# receive a signal like this.
	# Signals: (1) SIGHUP; (2) SIGINT; (15) SIGTERM.
	trap "rm ${SCRAP_FOLDER}/${POKEMON_NAME}.png; echo Download of ${POKEMON_NAME} was cancelled; exit" 1 2 15

	echo "  > Downloading '$POKEMON_NAME' from '$POKEMON_URL' to '$SCRAP_FOLDER/${POKEMON_NATIONAL_DEX_NUMBER}_${POKEMON_NAME}.png' ..."
	wget "$POKEMON_URL" -O "${SCRAP_FOLDER}/${POKEMON_NATIONAL_DEX_NUMBER}_${POKEMON_NAME}.png" -q
done

POKEMON_TOTAL=$(echo "$POKEMON_IMAGES" | wc -l)
echo "Done ! Downloaded $POKEMON_TOTAL Pokemon !"