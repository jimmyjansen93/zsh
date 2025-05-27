#!/usr/bin/env bash

log() {
  green='\033[0;32m'
  nc='\033[0m'
  echo -e "${green}LOG:${nc} $1"
}

error() {
  red='\033[0;31m'
  nc='\033[0m'
  echo -e "${red}ERROR: $1${nc}"
}

warning() {
  orange='\033[0;38;5;208m'
  nc='\033[0m'
  echo -e "${orange}WARNING:${nc} $1"
}

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_FILE="$HOME/.zshrc"

log "Removing existing symlink for .zshrc"
rm -f "$ZSHRC_FILE"
log "Creating symlink for .zshrc"
ln -sf "$CONFIG_DIR/.zshrc" "$ZSHRC_FILE"
log "Symlink created: $ZSHRC_FILE -> $CONFIG_DIR/.zshrc"
