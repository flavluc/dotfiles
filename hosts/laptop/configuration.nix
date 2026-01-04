# Laptop-specific configuration
{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # Networking hostname
  networking.hostName = "laptop";

  # Laptop-specific configurations can be added here
  # For example: battery management, power profiles, etc.
}
