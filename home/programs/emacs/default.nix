
{ pkgs, ... }:

let
  emacs-overlay = import (
    builtins.fetchTarball {
      url =
        "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
    }
  );
in
{
  nixpkgs.overlays = [ emacs-overlay ];

  programs.emacs = {
    enable = true;
    extraPackages = (
      epkgs:
      (
        with epkgs; [
          use-package
	  doom-modeline
        ]
      )
    );
  };

  home.file = {
    ".emacs.d" = {
      source = ./emacs.d;
      recursive = true;
    };
  };

  xresources.properties = {
    "Emacs.menuBar" = false;
    "Emacs.toolBar" = false;
    "Emacs.verticalScrollBars" = false;
  };

  services.emacs.enable = true;
}