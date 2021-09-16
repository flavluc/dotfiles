{ pkgs, ... }:

{
  home.packages = [];

  programs.home-manager = {
    enable = true;
  };
}
