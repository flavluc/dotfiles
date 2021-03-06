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
    
    # work stuff
    extraHosts = ''
      127.0.0.1   model-marketplace-server
      127.0.0.1   model-marketplace-database model-market-place-database
      127.0.0.1   model-marketplace-client
      127.0.0.1   postgres
    '';
  };

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    firefox
  ];

  environment.shellAliases = {
    "alacritty" = "nixGL alacritty";
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    extraConfig = ''
      load-module module-switch-on-connect
    '';
  };

  virtualisation.docker.enable = true;

  fonts = {
    fonts = with pkgs; [
      customFonts
      myfonts.icomoon-feather
      dejavu_fonts
      ipafont
      kochi-substitute
      source-code-pro
      emacs-all-the-icons-fonts
    ];

    fontconfig.defaultFonts = {
      monospace = ["Iosevka Sans Mono" "IPAGothic"];
      sansSerif = ["Iosevka Sans" "IPAPGothic"];
      serif = ["Iosevka Serif" "IPAPMincho"];
    };
  };

  i18n.inputMethod.enabled = "fcitx";
  i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];

  programs.fish.enable = true;

  users.users.fuyu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
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

  system.stateVersion = "21.05";
}
