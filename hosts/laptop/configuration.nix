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

  # Auto-detect external monitors: udev triggers autorandr on hotplug, so
  # plugging/unplugging a monitor reconfigures the displays without manual
  # xrandr. With no saved profile matching, fall back to extending the
  # desktop horizontally across whatever is connected.
  # Save named setups with e.g. `autorandr --save docked` and they take
  # precedence over the fallback.
  services.autorandr = {
    enable = true;
    defaultTarget = "horizontal";
  };

  # Laptop-specific configurations can be added here
  # For example: battery management, power profiles, etc.
}
