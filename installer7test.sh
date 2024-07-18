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

  echo -e "${CYAN} Do you want to install $font_name? (y/n)${NC}"
  read install_font

  if [[ $install_font =~ ^[yY]$ ]]; then
    echo -e "${PURPLE} Installing $font_name...${NC}"
    wget -q "$font_url" -O "/tmp/${font_name}.zip"

    if [ $? -ne 0 ]; then
      echo -e "${RED} Failed to download $font_name${NC}"
      log_error "Failed to download $font_name from $font_url"
    else
      echo -e "${GREEN} Successfully downloaded $font_name${NC}"
      mkdir -p "$FONT_DIR"
      unzip -q "/tmp/${font_name}.zip" -d "$FONT_DIR"

      if [ $? -ne 0 ]; then
        echo -e "${RED} Failed to extract $font_name${NC}"
        log_error "Failed to extract $font_name from /tmp/${font_name}.zip"
      else
        echo -e "${GREEN} Successfully installed $font_name${NC}"
        fc-cache -f -v "$FONT_DIR"
        ((installed_fonts_count++))
      fi
    fi

    rm -f "/tmp/${font_name}.zip"  # Clean up downloaded zip file
  else
    echo -e "${PURPLE} Skipping $font_name...${NC}"
  fi
}

# Main installation function
install_fonts_detailed() {
  echo -e "${GREEN} Installing fonts...${NC}"

  while IFS= read -r line; do
    if [[ ! "$line" =~ ^\s*# && ! "$line" =~ ^\s*$ ]]; then
      font_name=$(echo "$line" | cut -d '"' -f 2)
      font_url=$(echo "$line" | cut -d '"' -f 4)
      install_font "$font_name" "$font_url"
    fi
  done < "$FONT_FILE"

  # Final message based on the number of fonts installed
  if [[ $installed_fonts_count -eq 0 ]]; then
    echo -e "${GREEN} No fonts installed!${NC}"
  elif [[ $installed_fonts_count -eq 1 ]]; then
    echo -e "${GREEN} The font was installed successfully!${NC}"
  else
    echo -e "${GREEN} Fonts installed successfully!${NC}"
  fi
}

# Start installation process
install_fonts_detailed
