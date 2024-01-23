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
      <home-manager/nixos>
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
    brightnessctl
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
    package = pkgs.pulseaudioFull;
    extraConfig = ''
      load-module module-switch-on-connect
    '';
  };

  virtualisation.docker.enable = true;

  fonts = {
    packages = with pkgs; [
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

  # i18n.inputMethod.enabled = "fcitx5";
  # i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];

  programs.fish.enable = true;

  users.users.fuyu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "video" ];
    shell = pkgs.fish;
  };

  home-manager.users.fuyu.imports = [ ./home/home.nix ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "fuyu" ];
    };

    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 7d";
    };

    extraOptions = ''
      keep-outputs     = true
      keep-derivations = true
    '';

  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  system.stateVersion = "21.05";
}
