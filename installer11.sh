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



# Function to install a single font
install_font() {
    font_name=$1
    download_url=$2
    
    echo -e "${CYAN} Installing $font_name... ${NC}"
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
    
    echo -e "${GREEN} $font_name installed successfully! ${NC}"
}

# Function to install fonts from a specified file
install_fonts() {
    fonts_file=$1

    # Check if the fonts file exists
    if [ ! -f "$fonts_file" ]; then
        echo -e "${RED} Error: Fonts file '$fonts_file' not found. ${NC}"
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

    echo -e "${GREEN} All fonts installed and cache updated! ${NC}"
}

# Function to display a list of fonts with pagination
browse_fonts() {
    fonts_file=$1
    page_size=25  # Number of fonts to display per page
    page=1       # Initial page number

    while true; do
        clear
        echo -e "${YELLOW} Available Fonts (Page $page): ${NC}"
        
        # Display fonts for the current page
        start=$(( (page - 1) * page_size + 1 ))
        end=$(( page * page_size ))
        index=0
        
        # Read the font list from the specified file and display
        while IFS= read -r line; do
            # Skip comment lines and empty lines
            if [[ $line =~ ^\s*# || ! $line ]]; then
                continue
            fi
            
            (( index++ ))
            
            if [ "$index" -ge "$start" ] && [ "$index" -le "$end" ]; then
                font_name=$(echo "$line" | awk '{print $1}' | tr -d '"')
                echo -e "${PURPLE}$index) $font_name${NC}"
            fi
            
        done < "$fonts_file"
        
        echo -e "${YELLOW} Enter font number to install ${NC} (N for next page, P for previous page, Q to back): "
        read -r choice
        
        case $choice in
            [0-9]*)
                # Install the chosen font if valid number
                if [ "$choice" -ge "$start" ] && [ "$choice" -le "$end" ]; then
                    selected_line=$(sed -n "${choice}p" "$fonts_file")
                    font_name=$(echo "$selected_line" | awk '{print $1}' | tr -d '"')
                    download_url=$(echo "$selected_line" | awk '{print $2}' | tr -d '"')
                    install_font "$font_name" "$download_url"
                    echo -e "${YELLOW} Press any key to continue... ${NC}"
                    read -n 1 -s
                else
                    echo -e "${RED} Invalid selection ${NC}"
                fi
                ;;
            [Nn])
                # Next page
                (( page++ ))
                ;;
            [Pp])
                # Previous page
                if [ "$page" -gt 1 ]; then
                    (( page-- ))
                else
                    echo -e "${RED} You are already on the first page ${NC}"
                fi
                ;;
            [Qq])
                # Quit browsing
                break
                ;;
            *)
                echo -e "${RED} Invalid choice ${NC}"
                ;;
        esac
    done
}


######################################################################################################### MENU
################################ MENU

# Main menu loop
while true; do
    # Main menu
    echo -e "${YELLOW} Choose an option:${NC}"
    echo -e "${PURPLE}   1) Install critical font ($CRITICAL_FONT_NAME) ${NC}"
    echo -e "${PURPLE}   2) Install all fonts from $FONT_FILE ${NC}"
    echo -e "${PURPLE}   3) Browse and install a font ${NC}"
    echo -e "${PURPLE}  Q) Quit ${NC}"
    read -p " Enter your choice: " choice

    case $choice in
        1)
            install_font "$CRITICAL_FONT_NAME" "$CRITICAL_FONT_URL"
            ;;
        2)
            install_fonts "$FONT_FILE"
            ;;
        3)
            browse_fonts "$FONT_FILE"
            ;;
        [Qq])
            echo -e "${YELLOW} Exiting... ${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED} Invalid choice ${NC}"
            ;;
    esac
done
