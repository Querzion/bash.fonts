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

# Locations
APPLICATION="fonts"
BASE="bash.$APPLICATION"
FILES="$BASE/files"
# Font links
FONT_FILE="$FILES/font_links.txt"
# Critical font
CRITICAL_FONT_NAME="JetBrains Mono"
CRITICAL_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
# Directory to install fonts
FONT_DIR="$HOME/.local/share/fonts"
# Define the error log file
ERROR_LOG="$HOME/font_installation_errors.log"

######################################################################################################### FONT INSTALLATION
################################ FONT INSTALLATION

# Function to log errors
log_error() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$ERROR_LOG"
}

# Counter for installed fonts
installed_fonts_count=0

# Function to install a single font
install_font() {
  local font_name="$1"
  local font_url="$2"
  local install_font=""

  echo -e "${CYAN}Do you want to install $font_name? (y/n) ${NC}"
  read install_font
  if [[ $install_font =~ ^[yY]$ ]]; then
    echo -e "${PURPLE}Installing $font_name...${NC}"
    wget -q "$font_url" -O "/tmp/${font_name}.zip"
    if [ $? -ne 0 ]; then
      echo -e "${RED}Failed to download $font_name${NC}"
      log_error "Failed to download $font_name from $font_url"
    else
      echo -e "${GREEN}Successfully downloaded $font_name${NC}"
      # Extract the font files to the user's local fonts directory
      mkdir -p ~/.local/share/fonts
      unzip -q "/tmp/${font_name}.zip" -d ~/.local/share/fonts
      if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to extract $font_name${NC}"
        log_error "Failed to extract $font_name from /tmp/${font_name}.zip"
      else
        echo -e "${GREEN}Successfully installed $font_name${NC}"
        # Update the font cache
        fc-cache -f -v ~/.local/share/fonts
        ((installed_fonts_count++))
      fi
    fi
    # Clean up downloaded zip file
    rm -f "/tmp/${font_name}.zip"
  else
    echo -e "${PURPLE}Skipping $font_name...${NC}"
  fi
}

# Count the number of font packages
font_count=$(grep -v '^\s*#' "$FONT_FILE" | grep -v '^\s*$' | wc -l)

# Main installation function
install_fonts_detailed() {
  local install_fonts=""
  local install_all_fonts=""

  echo -e "${CYAN}Do you want to install fonts to your system? (y/n) ${NC}"
  read install_fonts
  if [[ $install_fonts =~ ^[nN]$ ]]; then
    # Install a critical font
    #CRITICAL_FONT_NAME="JetBrains Mono"
    #CRITICAL_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
    echo -e "${PURPLE}Installing critical font: $CRITICAL_FONT_NAME${NC}"
    install_font "$CRITICAL_FONT_NAME" "$CRITICAL_FONT_URL"
  else
    echo -e "${CYAN}Do you want to install all $font_count font packages? (y/n) ${NC}"
    read install_all_fonts
    if [[ $install_all_fonts =~ ^[yY]$ ]]; then
      while IFS= read -r line; do
        if [[ ! "$line" =~ ^\s*# && ! "$line" =~ ^\s*$ ]]; then
          font_name=$(echo "$line" | cut -d '"' -f 2)
          font_url=$(echo "$line" | cut -d '"' -f 4)
          install_font "$font_name" "$font_url"
        fi
      done < "$FONT_FILE"
    else
      while IFS= read -r line; do
        if [[ ! "$line" =~ ^\s*# && ! "$line" =~ ^\s*$ ]]; then
          font_name=$(echo "$line" | cut -d '"' -f 2)
          font_url=$(echo "$line" | cut -d '"' -f 4)
          install_font "$font_name" "$font_url"
        fi
      done < "$FONT_FILE"
    fi
  fi

  # Final message based on the number of fonts installed
  if [[ $installed_fonts_count -eq 0 ]]; then
    echo -e "${GREEN}No fonts installed!${NC}"
  elif [[ $installed_fonts_count -eq 1 ]]; then
    echo -e "${GREEN}The font was installed successfully!${NC}"
  else
    echo -e "${GREEN}Fonts installed successfully!${NC}"
  fi
}

######################################################################################################### MAIN
################################ MAIN

echo -e "${GREEN} First lets get the NerdFonts! All of them? ALL OF THEM! ${NC}"
echo -e "${YELLOW} Well, only if you want! Press something else then Y/y, and you will install the default critical font JetBrains Mono ${NC}"

install_fonts_detailed

echo -e "${GREEN} Fonts installed successfully! ${NC}"
