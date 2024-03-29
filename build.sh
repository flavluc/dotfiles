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
  sudo rm -rf /etc/nixos/home
  sudo cp -r home /etc/nixos/home
}

install_nixGL(){
  echo "Installing nixGL..."
  nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl && nix-channel --update
  nix-env -iA nixgl.auto.nixGLDefault
}

# https://github.com/NixOS/nixpkgs/issues/59927
xbacklight_permissions(){
  sudo chown root:video /sys/class/backlight/intel_backlight/brightness
  sudo chmod 0664 /sys/class/backlight/intel_backlight/brightness
}

build_system() {
  create_config

  sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
  sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

  sudo nixos-rebuild switch --upgrade
}

build_system