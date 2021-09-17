{ config, pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_5_14;

    supportedFilesystems = [ "ntfs" ];

    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    loader.grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
      extraEntries = ''
          menuentry "Windows" {
            insmod part_gpt
            insmod fat
            insmod search_fs_uuid
            insmod chain
            search --fs-uuid --set=root 1980-01-01-00-00-00-00
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
        '';
    };
  };

  networking = {
    hostName = "insp-nix";
    interfaces.enp2s0.useDHCP = true;
    interfaces.wlp3s0.useDHCP = true;
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];

    xrandrHeads = [
      { output = "HDMI-A-0";
        primary = true;
        monitorConfig = ''
          Modeline "3840x2160_30.00"  338.75  3840 4080 4488 5136  2160 2163 2168 2200 -hsync +vsync
          Option "PreferredMode" "3840x2160_30.00"
          Option "Position" "0 0"
        '';
      }
      { output = "eDP";
        monitorConfig = ''
          Option "PreferredMode" "1920x1080"
          Option "Position" "0 0"
        '';
      }
    ];

    resolutions = [
      { x = 2048; y = 1152; }
      { x = 1920; y = 1080; }
      { x = 2560; y = 1440; }
      { x = 3072; y = 1728; }
      { x = 3840; y = 2160; }
    ];
  };



}
