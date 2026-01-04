#!/usr/bin/env bash
set -e # Exit on error

# Get the directory where this script is located
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

create_folders() {
  echo "Preparing logs..."
  mkdir -p "$HOME/.config/polybar/logs"
  touch "$HOME/.config/polybar/logs/bottom.log" "$HOME/.config/polybar/logs/top.log"
}

build_system() {
  create_folders
  
  echo "Building NixOS Flake..."
  # Replace 'laptop' with your actual hostname defined in flake.nix
  sudo nixos-rebuild switch --flake "$SCRIPT_DIR#laptop"
}

build_system
