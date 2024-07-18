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
FONT_DIR="$HOME/.local/share/fonts"

# Critical font details
CRITICAL_FONT_NAME="JetBrains Mono"
CRITICAL_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"


######################################################################################################### FONT INSTALLATION
################################ FONT INSTALLATION

install_font() {
    font_name=$1
    download_url=$2
    
    echo -e "${CYAN}Installing $font_name...${NC}"
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
    
    echo -e "${GREEN}$font_name installed successfully!${NC}"
}

# Function to install fonts from a specified file
install_fonts() {
    fonts_file=$1

    # Check if the fonts file exists
    if [ ! -f "$fonts_file" ]; then
        echo -e "${RED}Error: Fonts file '$fonts_file' not found.${NC}"
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

    echo -e "${GREEN}All fonts installed and cache updated!${NC}"
}

# Function to display and install a single font from the list
install_single_font() {
    fonts_file=$1

    # Check if the fonts file exists
    if [ ! -f "$fonts_file" ]; then
        echo -e "${RED}Error: Fonts file '$fonts_file' not found.${NC}"
        exit 1
    fi

    # Display font list with numbers
    echo -e "${YELLOW}Available fonts:${NC}"
    font_list=()
    i=1
    while IFS= read -r line; do
        # Skip comment lines and empty lines
        if [[ $line =~ ^\s*# || ! $line ]]; then
            continue
        fi
        
        # Parse font name and download URL
        font_name=$(echo "$line" | awk '{print $1}' | tr -d '"')
        download_url=$(echo "$line" | awk '{print $2}' | tr -d '"')
        
        # Add to font list and display
        font_list+=("$font_name $download_url")
        echo -e "${PURPLE}$i) $font_name${NC}"
        ((i++))
        
    done < "$fonts_file"

    # Prompt user to choose a font
    read -p "Enter the number of the font to install: " font_choice

    # Validate choice
    if ! [[ "$font_choice" =~ ^[0-9]+$ ]] || [ "$font_choice" -lt 1 ] || [ "$font_choice" -gt "${#font_list[@]}" ]; then
        echo -e "${RED}Invalid choice${NC}"
        exit 1
    fi

    # Install the chosen font
    chosen_font="${font_list[$((font_choice-1))]}"
    chosen_font_name=$(echo "$chosen_font" | awk '{print $1}')
    chosen_font_url=$(echo "$chosen_font" | awk '{print $2}')
    install_font "$chosen_font_name" "$chosen_font_url"
}


######################################################################################################### MENU
################################ MENU

echo -e "${YELLOW}Choose an option:${NC}"
echo -e "${PURPLE}1) Install critical font ($CRITICAL_FONT_NAME)${NC}"
echo -e "${PURPLE}2) Install all fonts from $FONT_FILE${NC}"
echo -e "${PURPLE}3) Install a single font from the list${NC}"
read -p "Enter your choice: " choice

case $choice in
    1)
        install_font "$CRITICAL_FONT_NAME" "$CRITICAL_FONT_URL"
        ;;
    2)
        install_fonts "$FONT_FILE"
        ;;
    3)
        install_single_font "$FONT_FILE"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac