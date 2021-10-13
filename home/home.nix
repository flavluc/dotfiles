{ config, lib, pkgs, stdenv, ... }:

let
  defaultPkgs = with pkgs; [
    anki-bin             # space repetition system
    any-nix-shell        # fish support for nix shell
    arandr               # simple GUI for xrandr
    asciinema            # record the terminal
    audacious            # simple music player
    betterdiscordctl     # a better discord
    bitwarden-cli        # command-line client for the password manager
    bottom               # alternative to htop & ytop
    cachix               # nix caching
    calibre              # e-book reader
    dconf2nix            # dconf (gnome) files to nix converter
    discord              # chat client for dev stuff
    dmenu                # application launcher
    docker-compose       # docker manager
    dive                 # explore docker layers
    duf                  # disk usage/free utility
    exa                  # a better `ls`
    fd                   # "find" for files
    gimp                 # gnu image manipulation program
    git-crypt            # encryption/decryption for files in a git repo
    gnupg                # free-software replacement for Symantec's PGP
    hyperfine            # command-line benchmarking tool
    killall              # kill processes by name
    libreoffice          # office suite
    libnotify            # notify-send command
    multilockscreen      # fast lockscreen based on i3lock
    ncdu                 # disk space info (a better du)
    neofetch             # command-line system information
    nix-doc              # nix documentation search tool
    nix-index            # files database for nixpkgs
    nixos-generators     # nix tool to generate isos
    nyancat              # the famous rainbow cat!
    manix                # documentation searcher for nix
    pavucontrol          # pulseaudio volume control
    paprefs              # pulseaudio preferences
    pasystray            # pulseaudio systray
    pinentry             # dialog programs for GnuPG
    playerctl            # music player controller
    prettyping           # a nicer ping
    pulsemixer           # pulseaudio mixer
    qbittorrent          # bittorrent client
    ripgrep              # fast grep
    rnix-lsp             # nix lsp server
    signal-desktop       # encrypted instant messaging service
    simplescreenrecorder # self-explanatory
    slack                # messaging client
    spotify              # music source
    tdesktop             # telegram messaging client
    teams                # the worst team communication platform ever created
    tldr                 # summary of a man page
    tree                 # display files in a tree view
    vlc                  # media player
    xclip                # clipboard support (also for neovim)
    yad                  # yet another dialog - fork of zenity
    zulip                # desktop client for zulip chat

    # fixes the `ar` error required by cabal
    # binutils-unwrapped
  ];

  devPkgs = with pkgs; [
    cargo
    dotnet-sdk_5
    elixir
    fsharp
    ghc
    gcc
    nodejs-14_x
    ocaml
    pythonFull
    rustc
    stack
  ];

  gitPkgs = with pkgs.gitAndTools; [
    diff-so-fancy # git diff with colors
    git-crypt     # git files encryption
    hub           # github command-line client
    tig           # diff and commit view
  ];

  gnomePkgs = with pkgs.gnome3; [
    eog            # image viewer
    evince         # pdf reader
    gnome-calendar # calendar
    nautilus       # file manager
  ];

  polybarPkgs = with pkgs; [
    font-awesome-ttf      # awesome fonts
    material-design-icons # fonts with glyphs
  ];

  xmonadPkgs = with pkgs; [
    networkmanager_dmenu   # networkmanager on dmenu
    networkmanagerapplet   # networkmanager applet
    nitrogen               # wallpaper manager
    xcape                  # keymaps modifier
    xorg.xkbcomp           # keymaps modifier
    xorg.xmodmap           # keymaps modifier
    xorg.xrandr            # display manager (X Resize and Rotate protocol)
    xorg.xbacklight        # screen brightness controler
  ];

in
{
  programs.home-manager.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      nur = import (import pinned/nur.nix) { inherit pkgs; };
    };
  };

  nixpkgs.overlays = [
    (import ./overlays/discord)
  ];

  imports = (import ./programs) ++ (import ./services) ++ [(import ./themes)];

  xdg = {
    enable = true;
    configFile."networkmanager-dmenu/config.ini".text = ''
      [dmenu]
      dmenu_command = rofi
      rofi_highlight = True
      [editor]
      gui_if_available = True
    '';
  };

  home = {
    username      = "fuyu";
    homeDirectory = "/home/fuyu";
    stateVersion  = "21.03";

    packages = builtins.concatLists [
      defaultPkgs
      devPkgs
      gitPkgs
      gnomePkgs
      polybarPkgs
      xmonadPkgs
    ];

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "emacs";
    };
  };

  # restart services on change
  systemd.user.startServices = "sd-switch";

  # notifications about home-manager news
  news.display = "silent";

  programs = {
    bat.enable = true;

    broot = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type file --follow";
      defaultOptions = [ "--height 20%" ];
      fileWidgetCommand = "fd --type file --follow";
    };

    htop = {
      enable = true;
      settings = {
        sort_direction = true;
        sort_key = "PERCENT_CPU";
      };
    };

    neovim = {
      enable = true;
      vimAlias = true;
    };

    obs-studio = {
      enable = true;
      plugins = [];
    };

    ssh.enable = true;

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [];
    };
  };

  services = {
    flameshot.enable = true;

    udiskie = {
      enable = true;
      tray = "always";
    };

    screen-locker = {
      enable = true;
      inactiveInterval = 30;
      lockCmd = "${pkgs.multilockscreen}/bin/multilockscreen -l dim";
      xautolockExtraOptions = [
        "Xautolock.killer: systemctl suspend"
      ];
    };
  };
}
