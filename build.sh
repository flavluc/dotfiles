#! /usr/bin/env bash

# Shows the output of every command
set +x

create_config() {
  echo "Creating config files..."

  mkdir -p $HOME/.config/polybar/logs
  touch $HOME/.config/polybar/logs/bottom.log
  touch $HOME/.config/polybar/logs/top.log

  sudo cp -r system/* /etc/nixos
  sudo cp -r system/* /etc/nixos
  sudo cp -r home /etc/nixos/home
}

build_system() {
  create_config

  sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
  sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

  sudo nixos-rebuild switch --upgrade
}

build_system