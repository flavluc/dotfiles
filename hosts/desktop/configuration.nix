# Desktop-specific configuration
{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # Networking hostname
  networking.hostName = "desktop";

  # NVIDIA RTX 3060 Ti: use the proprietary driver instead of nouveau.
  # nouveau on Ampere can't reinitialize the display after suspend (black
  # screen on resume); the nvidia driver with powerManagement saves/restores
  # VRAM across suspend, which fixes it.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    # Enables nvidia-suspend/resume services and preserves video memory
    # allocations across sleep — this is the actual fix for the black screen.
    powerManagement.enable = true;
    # Open kernel module is the supported choice for Turing+ (GA104 included).
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Desktop-specific: Hard drive filesystem
  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/F262BEB362BE7C43";
    fsType = "ntfs";
    options = [ "uid=1000" "gid=100" "umask=022" ];
  };
}
