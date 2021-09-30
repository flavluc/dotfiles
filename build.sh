#! /usr/bin/env bash

# Shows the output of every command
set +x

prepare_home() {
  echo "Creating config..."

  mkdir -p $HOME/.config/polybar/logs
  touch $HOME/.config/polybar/logs/bottom.log
  touch $HOME/.config/polybar/logs/top.log

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

  echo "Running Home Manager switch..."
  home-manager switch -b /dev/null
}

build_system() {
  sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
  sudo cp -r system/* /etc/nixos
  sudo nixos-rebuild -I nixpkgs=$(cat ./pinned/nixpkgs) switch --upgrade
}

build_all() {
  echo "Building system and home."
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
