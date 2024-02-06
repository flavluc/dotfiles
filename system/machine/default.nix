{ config, pkgs, ... }:

{
  boot = {
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
    };
  };

  networking = {
    hostName = "insp-nix";
    interfaces.enp2s0.useDHCP = true;
    interfaces.wlp3s0.useDHCP = true;
  };

  services.logind = {
    lidSwitch = "suspend";
  };

  # https://discourse.nixos.org/t/keyboard-touchpad-do-not-wake-after-closing-laptop-lid/7565/7
  powerManagement.resumeCommands = "${pkgs.kmod}/bin/rmmod atkbd; ${pkgs.kmod}/bin/modprobe atkbd reset=1";

  services.xserver = {
    xrandrHeads = [
      { output = "HDMI-A-0";
        primary = true;
        monitorConfig = ''
          Option "PreferredMode" "1920x1080"
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
  };
}
