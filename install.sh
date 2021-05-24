#!/bin/sh

# Define install directories and names
INSTALL_PATH="$HOME/.bin/pokemonsay"
BIN_PATH="/bin"
POKEMONSAY_BIN="pokemonsay"
POKEMONTHINK_BIN="pokemonthink"

# Make sure the directories exist
mkdir -p $INSTALL_PATH/
mkdir -p $INSTALL_PATH/pokemons/
mkdir -p $BIN_PATH/

# Copy the cows and the main script to the install path.
cp ./pokemons/*.cow $INSTALL_PATH/pokemons/
cp ./pokemonsay.sh $INSTALL_PATH/
cp ./pokemonthink.sh $INSTALL_PATH/

sudo ln -sf "${INSTALL_PATH}/${POKEMONSAY_BIN}.sh" "${BIN_PATH}/${POKEMONSAY_BIN}"
sudo ln -sf "${INSTALL_PATH}/${POKEMONTHINK_BIN}.sh" "${BIN_PATH}/${POKEMONTHINK_BIN}"

# Create uninstall script in the install directory
cat > $INSTALL_PATH/uninstall.sh <<- EOF
	#!/bin/sh

	#
	# This script uninstalls pokemonsay.
	#

	# Remove the install directory
	rm -r "$INSTALL_PATH/"

	# Remove the bin files symbolic links
	sudo rm "$BIN_PATH/$POKEMONSAY_BIN"
	sudo rm "$BIN_PATH/$POKEMONTHINK_BIN"

	# Say what's going on.
	echo "'$INSTALL_PATH/' directory was removed."
	echo "'$BIN_PATH/$POKEMONSAY_BIN' file was removed."
	echo "'$BIN_PATH/$POKEMONTHINK_BIN' file was removed."
EOF

# Change permission of the generated scripts
chmod +x "$INSTALL_PATH/uninstall.sh"

echo "The files were installed to '$INSTALL_PATH/'."
echo "A '$POKEMONSAY_BIN' script was created in '$BIN_PATH/'."
echo "A uninstall script was created in '$INSTALL_PATH/'."
echo "It may be necessary to logout and login back again in order to have the '$POKEMONSAY_BIN' available in your path."
