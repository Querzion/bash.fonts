#!/bin/bash

# Define color variables
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color


######################################################################################################### FILE & FOLDER PATHS
################################ FILE & FOLDER PATHS

APPLICATION="fonts"
BASE="bash.$APPLICATION"
FILES="$BASE/files"
FONT_FILE="$FILES/fonts.txt"
CRITICAL_FONT_NAME="JetBrains Mono"
CRITICAL_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
FONT_DIR="$HOME/.local/share/fonts"


######################################################################################################### FONT INSTALLATION
################################ FONT INSTALLATION

# Function to install fonts
install_fonts() {
    fonts_file=$1

    # Function to install a single font
    install_font() {
        font_name=$1
        download_url=$2
        
        echo "Installing $font_name..."
        temp_dir=$(mktemp -d)
        
        # Download the font zip file
        curl -L -o "$temp_dir/font.zip" "$download_url"
        
        # Unzip the font files
        unzip -q "$temp_dir/font.zip" -d "$temp_dir"
        
        # Create font directory if not exists
        mkdir -p "$FONT_DIR"
        
        # Move all font files to user fonts directory
        find "$temp_dir" -name '*.otf' -or -name '*.ttf' -exec mv {} "$FONT_DIR" \;
        
        # Clean up
        rm -rf "$temp_dir"
        
        echo "$font_name installed successfully!"
    }

    # Check if the fonts file exists
    if [ ! -f "$fonts_file" ]; then
        echo "Error: Fonts file '$fonts_file' not found."
        exit 1
    fi

    # Read the font list from the specified file
    while IFS= read -r line; do
        # Skip comment lines and empty lines
        if [[ $line =~ ^\s*# || ! $line ]]; then
            continue
        fi
        
        # Parse font name and download URL
        font_name=$(echo "$line" | awk '{print $1}' | tr -d '"')
        download_url=$(echo "$line" | awk '{print $2}' | tr -d '"')
        
        # Install the font
        install_font "$font_name" "$download_url"
        
    done < "$fonts_file"

    # Refresh font cache
    fc-cache -f -v

    echo "All fonts installed and cache updated!"
}


######################################################################################################### MAIN
################################ MAIN

# Call the function to install fonts using the predefined FONT_FILE path
install_fonts "$FONT_FILE"
