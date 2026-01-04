# Desktop-specific configuration
{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # Networking hostname
  networking.hostName = "desktop";

  # Desktop-specific: Hard drive filesystem
  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/F262BEB362BE7C43";
    fsType = "ntfs";
    options = [ "uid=1000" "gid=100" "umask=022" ];
  };
}
