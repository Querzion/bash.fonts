#!/bin/bash

# Define color variables
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# File and folder paths
APPLICATION="fonts"
BASE="bash.$APPLICATION"
FILES="$BASE/files"
FONT_FILE="$FILES/fonts.txt"
CRITICAL_FONT_NAME="JetBrains Mono"
CRITICAL_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
FONT_DIR="$HOME/.local/share/fonts"


# Flag to track if any fonts were installed
fonts_installed=false

# Function to install a font from a zip file
install_font_from_zip() {
    local zip_file="$1"
    local font_name="$2"

    echo -e "${CYAN}Installing font: ${font_name}${NC}"

    # Check if font is already installed
    if fc-list | grep -q "$font_name"; then
        echo -e "${GREEN}Font '${font_name}' is already installed.${NC}"
    else
        # Extract the font files
        unzip -q "$zip_file" -d "$FONT_DIR"
        echo -e "${GREEN}Font '${font_name}' installed.${NC}"
        fonts_installed=true
    fi
}

# Read fonts from fonts.txt and install them
while read -r line; do
    font_name=$(echo "$line" | awk '{print $1}')
    font_url=$(echo "$line" | awk '{print $2}')

    # Download the zip file
    zip_file="$FONT_DIR/$(basename "$font_url")"
    wget -q --show-progress -O "$zip_file" "$font_url"

    # Install fonts from the zip file
    install_font_from_zip "$zip_file" "$font_name"

    # Clean up downloaded zip file
    rm "$zip_file"
    
    # Assume we only need to install one font
    break
done < "$FONT_FILE"

# If no fonts were installed, install critical font
if ! $fonts_installed; then
    # Download critical font zip file
    zip_file="$FONT_DIR/$(basename "$CRITICAL_FONT_URL")"
    wget -q --show-progress -O "$zip_file" "$CRITICAL_FONT_URL"

    # Install critical font from the zip file
    install_font_from_zip "$zip_file" "$CRITICAL_FONT_NAME"

    # Clean up downloaded zip file
    rm "$zip_file"
fi

# Display completion message only if fonts were installed
if $fonts_installed; then
    echo -e "${CYAN}Font installation complete.${NC}"
else
    echo -e "${YELLOW}No new fonts installed.${NC}"
fi
