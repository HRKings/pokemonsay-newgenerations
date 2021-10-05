#!/bin/sh

usage() {
	echo
	echo "  Description: Pokemonsay makes a pokemon say something to you."
	echo
	echo "  Usage: $(basename "$0") [-p POKEMON_NAME] [-f COW_FILE] [-w COLUMN] [-l] [-n] [-t] [-h] [MESSAGE]"
	echo
	echo "  Options:"
	echo "    -p, --pokemon POKEMON_NAME"
	echo "      Choose what pokemon will be used by its name."
	echo "    -d, --nationalDex NATIONAL_DEX_NUMBER"
	echo "      Choose what pokemon will be used by its national dex number."
	echo "    -D, --nationalDexForms NATIONAL_DEX_NUMBER"
	echo "      Choose what pokemon will be used by its national dex number (With a random form for the chosen pokemon)."
	echo "    -f, --file COW_FILE"
	echo "      Specify which .cow file should be used."
	echo "    -W, --word-wrap COLUMN"
	echo "      Specify roughly where messages should be wrapped."
	echo "    -n, --no-wrap"
	echo "      Do not wrap the messages."
	echo "    -l, --list"
	echo "      List all the pokemon available."
	echo "    -L, --listForms"
	echo "      List all the pokemon alternate forms available."
	echo "    -N, --no-name"
	echo "      Do not tell the pokemon name."
	echo "    -t, --think"
	echo "      Make the pokemon think the message, instead of saying it."
	echo "    -h, --help"
	echo "      Display this usage message."
	echo "    MESSAGE"
	echo "      What the pokemon will say. If you don't provide a message, a message will be read form standard input."
	exit 0
}

INSTALL_PATH=${HOME}/.bin/pokemonsay
# Where the pokemon are.
POKEMON_PATH=${INSTALL_PATH}/pokemons

list_pokemon() {
	echo "Pokemon available in '$POKEMON_PATH/':"
	echo
	ALL_POKEMON="$(find $POKEMON_PATH -regextype sed -regex "${POKEMON_PATH}/[0-9]\+\w*[^\-]\.cow" | sort)"
	echo "$ALL_POKEMON" | while read -r POKEMON; do
		POKEMON=${POKEMON##*/}
		POKEMON=${POKEMON%.cow}
		DEX=${POKEMON%_*}
		POKEMON=${POKEMON##*_}
		echo "$DEX - ${POKEMON^}"
	done
	exit 0
}

list_pokemon_forms() {
	echo "Pokemon available in '$POKEMON_PATH/':"
	echo
	ALL_POKEMON="$(find $POKEMON_PATH -regextype sed -regex ".*[\-]\+.*\.cow" | sort)"
	echo "$ALL_POKEMON" | while read -r POKEMON; do
		POKEMON=${POKEMON##*/}
		POKEMON=${POKEMON%.cow}
		DEX=${POKEMON%_*}
		POKEMON=${POKEMON##*_}
		echo "$DEX - $POKEMON"
	done
	exit 0
}

# While there are arguments, keep reading them.
while [ $# -gt 0 ]
do
key="$1"
case $key in
	-p|--pokemon)
		POKEMON_NAME="$2"
		shift; shift
		;;
	-p=*|--pokemon=*)
		POKEMON_NAME="${1#*=}"
		shift
		;;
	-d|--nationalDex)
		NATIONAL_DEX="$2"
		shift; shift
		;;
	-d=*|--nationalDex=*)
		NATIONAL_DEX="${1#*=}"
		shift
		;;
	-D|--nationalDexForms)
		NATIONAL_DEX_FORMS="$2"
		shift; shift
		;;
	-D=*|--nationalDexForms=*)
		NATIONAL_DEX_FORMS="${1#*=}"
		shift
		;;
	-f|--file)
		COW_FILE="$2"
		shift; shift
		;;
	-f=*|--file=*)
		COW_FILE="${1#*=}"
		shift
		;;
	-W|--word-wrap)
		WORD_WRAP="$2"
		shift; shift
		;;
	-W=*|--word-wrap=*)
		WORD_WRAP="${1#*=}"
		shift
		;;
	-n|--no-wrap)
		DISABLE_WRAP="YES"
		shift
		;;
	-l|--list)
		list_pokemon
		;;
	-L|--listForms)
		list_pokemon_forms
		;;
	-N|--no-name)
		DISPLAY_NAME="NO"
		shift
		;;
	-t|--think)
		THINK="YES"
		shift
		;;
	-h|--help)
		usage
		;;
	-*)
		echo
		echo "  Unknown option '$1'"
		usage
		;;
	*)
		# Append this word to the message.
		if [ -n "$MESSAGE" ]; then
			MESSAGE="$MESSAGE $1"
		else
			MESSAGE="$1"
		fi
		shift
		;;
esac
done

# Disable wrapping if the option is set, otherwise
# define where to wrap the message.
if [ "${DISABLE_WRAP}" = "YES" ]; then
	word_wrap="-n"
elif [ -n "$WORD_WRAP" ]; then
	word_wrap="-W $WORD_WRAP"
fi

# Define which pokemon should be displayed.
if   [ -n "$POKEMON_NAME" ]; then
	POKEMON_COW=$(find $POKEMON_PATH -iname "*$POKEMON_NAME.cow" | shuf -n 1)
elif [ -n "$NATIONAL_DEX" ]; then
	POKEMON_COW=$(find $POKEMON_PATH -regextype sed -regex ".*${NATIONAL_DEX}\_\w*[^\-]\.cow" | shuf -n 1)
elif [ -n "$NATIONAL_DEX_FORMS" ]; then
	POKEMON_COW=$(find $POKEMON_PATH -name "${NATIONAL_DEX_FORMS}_*.cow" | shuf -n 1)
elif [ -n "$COW_FILE" ]; then
	POKEMON_COW="$COW_FILE"
else
	POKEMON_COW=$(find $POKEMON_PATH -name "*.cow" | shuf -n 1)
fi

# Get the pokemon name.
FILENAME=$(basename "$POKEMON_COW")
POKEMON_NAME="${FILENAME%.*}"
POKEMON_NAME="${POKEMON_NAME##*_}"

# Call cowsay or cowthink.
if [ -n "$THINK" ]; then
	cowthink -f "$POKEMON_COW" "$word_wrap" "$MESSAGE"
else
	cowsay -f "$POKEMON_COW" "$word_wrap" "$MESSAGE"
fi

# Write the pokemon name, unless requested otherwise.
if [ -z "$DISPLAY_NAME" ]; then
	echo "${POKEMON_NAME}"
fi
