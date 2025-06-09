{ config, pkgs, ... }:

let
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
      127.0.0.1 neomaril-database
      127.0.0.1 neomaril-pubsub-channel
      127.0.0.1 neomaril-airflow
      127.0.0.1 neomaril-mlflow
      127.0.0.1 neomaril-facing
      127.0.0.1 neomaril-serving
      127.0.0.1 neomaril-blobstorage
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

# TODO fix sound
#  sound = {
#    enable = true;
#    mediaKeys.enable = true;
#  };

  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

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
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
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
  home-manager.backupFileExtension = "backup";

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "fuyu" ];
      experimental-features = [ "nix-command" "flakes" ];
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
