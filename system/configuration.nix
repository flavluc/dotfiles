{ config, pkgs, ... }:

let
  customFonts = pkgs.nerdfonts.override {
    fonts = [
      "JetBrainsMono"
      "Iosevka"
    ];
  };

  myfonts = pkgs.callPackage fonts/default.nix { inherit pkgs; };
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./machine
      ./wm
    ];

  networking = {
    networkmanager = {
      enable   = true;
    };
    useDHCP = false;
  };

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    firefox
  ];

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  fonts.fonts = with pkgs; [
    customFonts
    carlito
    dejavu_fonts
    ipafont
    kochi-substitute
    source-code-pro
    ttf_bitstream_vera
    emacs-all-the-icons-fonts
  ];

  programs.fish.enable = true;

  users.users.fuyu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    autoOptimiseStore = true;

    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 7d";
    };

    extraOptions = ''
      keep-outputs     = true
      keep-derivations = true
    '';

    trustedUsers = [ "root" "fuyu" ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  i18n.inputMethod.enabled = "fcitx";
  i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];

  system.stateVersion = "21.05";
}
