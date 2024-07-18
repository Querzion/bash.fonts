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
ERROR_LOG="$HOME/font_installation_errors.log"

# Function to update font cache
update_font_cache() {
    print_message "${YELLOW}" "Updating font cache..."
    fc-cache -f -v
}

# Function to install fonts
install_font() {
    local font_name="$1"
    local font_url="$2"
    print_message "${CYAN}" "Installing font: $font_name"
    
    # Temporary directory for downloading and extracting font
    local temp_dir=$(mktemp -d)

    # Download the font zip file
    curl -LO "$font_url" || { print_message "${RED}" "Failed to download font: $font_name"; return 1; }

    # Extract the font zip file to a temporary directory
    unzip font.zip -d "$temp_dir" || { print_message "${RED}" "Failed to extract font: $font_name"; return 1; }

    # Determine the extracted font folder name
    local extracted_dir=$(find "$temp_dir" -mindepth 1 -maxdepth 1 -type d | head -1)

    if [ -z "$extracted_dir" ]; then
        print_message "${RED}" "Error: Failed to locate extracted font folder."
        return 1
    fi

    # Move the extracted font folder to FONT_DIR with the font_name as its folder name
    mkdir -p "$FONT_DIR/$font_name"
    mv "$extracted_dir"/* "$FONT_DIR/$font_name/"

    # Clean up: Remove the temporary directory
    rm -rf "$temp_dir"
}

# Function to print message with color
print_message() {
    local color="$1"
    shift
    local message="$@"
    echo -e "${color}${message}${NC}"
}

# Check if fonts.txt exists and is readable
if [ ! -f "$FONT_FILE" ]; then
    print_message "${RED}" "Error: Font file ($FONT_FILE) not found or not readable."
    exit 1
fi

# Count number of fonts in FONT_FILE
num_fonts=$(grep -c "font name" "$FONT_FILE")

# Prompt user to install all fonts
read -p "$(print_message "${PURPLE}" "Do you want to add all $num_fonts fonts to your system? (y/n): ")" install_all_fonts

if [ "$install_all_fonts" = "y" ]; then
    # Install all fonts
    while IFS=$'\t' read -r font_name font_url _; do
        if [[ "$font_name" != \#* ]]; then  # Ignore commented lines
            install_font "$font_name" "$font_url"
            update_font_cache
        fi
    done < "$FONT_FILE"
else
    # Prompt user to install critical font only
    read -p "$(print_message "${PURPLE}" "Do you want to only add $CRITICAL_FONT_NAME to the system? (Critical Font) (y/n): ")" install_critical_font

    if [ "$install_critical_font" = "y" ]; then
        # Install critical font
        install_font "$CRITICAL_FONT_NAME" "$CRITICAL_FONT_URL"
    else
        # Install fonts line by line
        while IFS=$'\t' read -r font_name font_url _; do
            if [[ "$font_name" != \#* ]]; then  # Ignore commented lines
                read -p "$(print_message "${PURPLE}" "Do you want to add '$font_name' to your system? (y/n): ")" install_this_font
                if [ "$install_this_font" = "y" ]; then
                    install_font "$font_name" "$font_url"
                    update_font_cache
                fi
            fi
        done < "$FONT_FILE"
    fi
fi

# Count installed fonts
installed_fonts=$(ls "$FONT_DIR" | wc -l)

# Display installation result
if [ "$installed_fonts" -eq 1 ]; then
    print_message "${GREEN}" "The font was successfully installed!"
else
    print_message "${GREEN}" "The $installed_fonts fonts were successfully installed!"
fi
