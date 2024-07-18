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


######################################################################################################### FONT INSTALLATION ('UN-DETAILED')
################################ FONT INSTALLATION ('UN-DETAILED')

# Function to handle all operations
install_fonts() {
  read -p "${CYAN}Do you want to download fonts? (y/n) ${NC}" download_fonts
  if [[ $download_fonts =~ ^[nN]$ ]]; then
    echo -e "${PURPLE}Installing critical font: $CRITICAL_FONT_NAME${NC}"
    wget -q "$CRITICAL_FONT_URL" -O /tmp/font.zip
    mkdir -p "$FONT_DIR"
    unzip -qo /tmp/font.zip -d "$FONT_DIR"
    fc-cache -f -v
    exit 0
  fi

  read -p "${CYAN}Do you want to download all fonts? (y/n) ${NC}" download_all
  while IFS= read -r line; do
    [[ $line =~ ^#.*$ ]] && continue
    # This part handles the spaces between the name and the link. 
    # This is restricted to only one space between name and link sections in the fonts.txt file.
    #name=$(echo $line | cut -d '"' -f2)
    #url=$(echo $line | cut -d '"' -f4)
    # This is not restricted to how big the space is between the section name and link is in the fonts.txt.
    name=$(echo $line | awk '{for(i=1;i<NF;i++) printf $i " "; print $NF}')
    url=$(echo $line | awk '{print $NF}')

    if [[ $download_all =~ ^[yY]$ ]] || { read -p "${PURPLE}Install $name? (y/n) ${NC}" answer && [[ $answer =~ ^[yY]$ ]]; }; then
      echo -e "${GREEN}Installing $name...${NC}"
      wget -q "$url" -O /tmp/font.zip
      mkdir -p "$FONT_DIR"
      unzip -qo /tmp/font.zip -d "$FONT_DIR"
      fc-cache -f -v
      echo -e "${GREEN}$name installed.${NC}"
    else
      echo -e "${RED}Skipping $name.${NC}"
    fi
  done < "$FONT_FILE"

  # Ensure the critical font is installed
  echo -e "${PURPLE}Ensuring the critical font is installed: $CRITICAL_FONT_NAME${NC}"
  wget -q "$CRITICAL_FONT_URL" -O /tmp/font.zip
  unzip -qo /tmp/font.zip -d "$FONT_DIR"
  fc-cache -f -v
}


######################################################################################################### FONT INSTALLATION (DETAILED)
################################ FONT INSTALLATION (DETAILED)

# Count the number of font packages
font_count=$(grep -v '^#' "$FONT_FILE" | wc -l)

# Function to handle all operations
install_fonts_detailed() {
  read -p "${CYAN}Do you want to install fonts to your system? (y/n) ${NC}" install_fonts
  if [[ $install_fonts =~ ^[nN]$ ]]; then
    echo -e "${PURPLE}Installing critical font: $CRITICAL_FONT_NAME${NC}"
    wget -q "$CRITICAL_FONT_URL" -O /tmp/font.zip
    mkdir -p "$FONT_DIR"
    unzip -qo /tmp/font.zip -d "$FONT_DIR"
    echo -e "Extracted files:"
    unzip -l /tmp/font.zip | awk '{print $2}' | tail -n +4 | head -n -2
    fc-cache -f -v
    exit 0
  fi

  read -p "${CYAN}Do you want to install all $font_count font packages? (y/n) ${NC}" download_all
  if [[ $download_all =~ ^[yY]$ ]]; then
    while IFS= read -r line; do
      [[ $line =~ ^#.*$ ]] && continue
      name=$(echo $line | awk '{for(i=1;i<NF;i++) printf $i " "; print $NF}')
      url=$(echo $line | awk '{print $NF}')

      echo -e "${CYAN}Installing $name...${NC}"
      wget -q "$url" -O /tmp/font.zip
      mkdir -p "$FONT_DIR"
      unzip -qo /tmp/font.zip -d "$FONT_DIR"
      echo -e "Extracted files:"
      unzip -l /tmp/font.zip | awk '{print $2}' | tail -n +4 | head -n -2
      fc-cache -f -v
      echo -e "${GREEN}$name installed.${NC}"
    done < "$FONT_FILE"
  else
    while IFS= read -r line; do
      [[ $line =~ ^#.*$ ]] && continue
      name=$(echo $line | awk '{for(i=1;i<NF;i++) printf $i " "; print $NF}')
      url=$(echo $line | awk '{print $NF}')

      read -p "${PURPLE}Do you want to install the $name font? (y/n) ${NC}" answer
      if [[ $answer =~ ^[yY]$ ]]; then
        echo -e "${CYAN}Installing $name...${NC}"
        wget -q "$url" -O /tmp/font.zip
        mkdir -p "$FONT_DIR"
        unzip -qo /tmp/font.zip -d "$FONT_DIR"
        echo -e "Extracted files:"
        unzip -l /tmp/font.zip | awk '{print $2}' | tail -n +4 | head -n -2
        fc-cache -f -v
        echo -e "${GREEN}$name installed.${NC}"
      else
        echo -e "${RED}Skipping $name.${NC}"
      fi
    done < "$FONT_FILE"
  fi

  # Ensure the critical font is installed
  echo -e "${PURPLE}Ensuring the critical font is installed: $CRITICAL_FONT_NAME${NC}"
  wget -q "$CRITICAL_FONT_URL" -O /tmp/font.zip
  unzip -qo /tmp/font.zip -d "$FONT_DIR"
  echo -e "Extracted files:"
  unzip -l /tmp/font.zip | awk '{print $2}' | tail -n +4 | head -n -2
  fc-cache -f -v
}


######################################################################################################### MAIN
################################ MAIN


echo -e "${GREEN} First lets get the NerdFonts! All of them? ALL OF THEM! ${NC}"
echo -e "${YELLOW} Well, only if you want! Press something else then Y/y, and you will install the default critical font JetBrains Mono ${NC}"

#install_fonts
install_fonts_detailed

echo -e "${GREEN} Fonts installed successfully! ${NC}"
