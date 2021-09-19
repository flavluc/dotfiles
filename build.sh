#! /usr/bin/env bash

# Shows the output of every command
set +x

prepare_home() {
  echo "Creating config..."

  # Polybar logs
  mkdir -p $HOME/.config/polybar/logs
  touch $HOME/.config/polybar/logs/bottom.log
  touch $HOME/.config/polybar/logs/top.log

  # Home manager files
  rm -rf $HOME/.config/doom-config
  mkdir -p $HOME/.config/doom-config
  cp -r home/programs/emacs/doom-config $HOME/.config

  # Home manager files
  rm -rf $HOME/.config/nixpkgs
  mkdir -p $HOME/.config/nixpkgs/
  cp -r home/* $HOME/.config/nixpkgs/
}

install_hm() {
  echo "Installing Home Manager..."
  nix-channel --add $(cat ./pinned/home-manager) home-manager
  nix-channel --update
  export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
  nix-shell '<home-manager>' -A install
}

build_home() {
  prepare_home
  install_hm

  # Switch to HM's latest build
  echo "Running Home Manager switch..."
  home-manager switch
}

build_system() {
  sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
  sudo cp system/configuration.nix /etc/nixos/
  sudo cp system/hardware-configuration.nix /etc/nixos/
  sudo cp -r system/fonts/ /etc/nixos/
  sudo cp -r system/machine/ /etc/nixos/
  sudo cp -r system/wm/ /etc/nixos/
  sudo nixos-rebuild -I nixpkgs=$(cat ./pinned/nixpkgs) switch --upgrade
}

build_all() {
  echo "No custom build option given. Building system and home."
  cmd="build_system && build_home"
  nix-shell --run "$cmd"
}

case $1 in
  "home")
    build_home;;
  "system")
    build_system;;
  *)
    build_all;;
esac
