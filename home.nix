{ config, pkgs, ... }:

{
  home.packages = [];

  users = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  programs.fish.enable = true;
}
