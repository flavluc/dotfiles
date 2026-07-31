# Laptop-specific configuration
{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # Networking hostname
  networking.hostName = "laptop";

  # ThinkPad ABNT2 keyboards put the "/ ? °" key on the <RCTL> keycode instead
  # of <AB11>, so under plain br(abnt2) the key is dead. This variant is just
  # br(abnt2) with <RCTL> remapped to slash/question/degree/questiondown.
  services.xserver.xkb.variant = "thinkpad";

  # Laptop-specific configurations can be added here
  # For example: battery management, power profiles, etc.
}
