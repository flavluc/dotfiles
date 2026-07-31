{ config, lib, pkgs, stdenv, ... }:

let
  defaultPkgs = with pkgs; [
    ffmpeg
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
    cloudflare-warp
    dbeaver-bin		       # universal SQL Client for developers
    dconf2nix            # dconf (gnome) files to nix converter
    discord              # chat client for dev stuff
    dmenu                # application launcher
    docker-compose       # docker manager
    dive                 # explore docker layers
    duf                  # disk usage/free utility
    eog                  # image viewer
    evince               # pdf reader
    foliate              # ebup reader
    gnome-calendar       # calendar
    nautilus             # file manager
    eza                  # a better `ls`
    fd                   # "find" for files
    gimp                 # gnu image manipulation program
    git-crypt            # encryption/decryption for files in a git repo
    google-chrome
    gh
    gnupg                # free-software replacement for Symantec's PGP
    hyperfine            # command-line benchmarking tool
    insomnia             # API client for GraphQL, REST, WebSockets, SSE and gRPC
    krita                # a free and open source painting application
    libreoffice          # office suite
    libnotify            # notify-send command
    logseq               # for organizing and sharing your personal knowledge base
    mongodb-compass      # GUI for MongoDB
    ncdu                 # disk space info (a better du)
    fastfetch            # command-line system information (replaces neofetch)
    nix-doc              # nix documentation search tool
    nix-index            # files database for nixpkgs+
    nixos-generators     # nix tool to generate isos
    nyancat              # the famous rainbow cat!
    manix                # documentation searcher for nix
    pavucontrol          # pulseaudio volume control
    paprefs              # pulseaudio preferences
    pasystray            # pulseaudio systray
    pciutils             # util commands for pci info
    pinentry-gnome3      # dialog programs for GnuPG (must pick a variant since 26.05)
    playerctl            # music player controller
    postman              # API development environment
    prettyping           # a nicer ping
    pulsemixer           # pulseaudio mixer
    qbittorrent          # bittorrent client
    ripgrep              # fast grep
    signal-desktop       # encrypted instant messaging service
    simplescreenrecorder # self-explanatory
    slack                # messaging client
    spotify              # music source
    syncthing            # open Source Continuous File Synchronization
    telegram-desktop     # telegram messaging client (renamed from tdesktop)
    tldr                 # summary of a man page
    todoist-electron     # task manager
    tree                 # display files in a tree view
    vlc                  # media player
    xclip                # clipboard support (also for neovim)
    karere               # whatsapp client (whatsapp-for-linux archived upstream)
    yad                  # yet another dialog - fork of zenity
    zulip                # desktop client for zulip chat
  ];

  devPkgs = with pkgs; [
    awscli2		           # unified tool to manage your AWS services
    babashka
    cargo
    clj-kondo
    clojure
    dotnet-sdk
    elixir
    fsharp
    gcc
    ghc
    leiningen
    nodejs
    tsx                  # TS runner (nodePackages.ts-node removed in 26.05)
    typescript           # moved to top level (was nodePackages.typescript)
    ocaml
    openjdk
    python3
    rlwrap
    rustc
    stack
    terraform
    turbo
    vscode
    claude-code
    zprint
  ];

  # gitAndTools was removed in 26.05; these are all top level now
  gitPkgs = with pkgs; [
    diff-so-fancy # git diff with colors
    git-crypt     # git files encryption
    hub           # github command-line client
    tig           # diff and commit view
  ];

  polybarPkgs = with pkgs; [
    font-awesome      # awesome fonts
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
  ];

in
{

  home = {
    username      = "flavio";
    homeDirectory = "/home/flavio";
    stateVersion  = "25.05";

    packages = builtins.concatLists [
      defaultPkgs
      devPkgs
      gitPkgs
      polybarPkgs
      xmonadPkgs
    ];

    pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 32;
    };

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "emacs";
    };
  };

  imports = (import ./programs) ++ (import ./services) ++ [(import ./themes)];
  
  nixpkgs.config = {
    allowUnfree = true;
  };

  xdg = {
    enable = true;
    configFile."networkmanager-dmenu/config.ini".text = ''
      [dmenu]
      dmenu_command = rofi
      rofi_highlight = True
      [editor]
      gui_if_available = True
    '';

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html"              = [ "firefox.desktop" ];
        "x-scheme-handler/http"  = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      };
    };
  };  

  # restart services on change
  systemd.user.startServices = "sd-switch";

  programs = {
    bat.enable = true;

    broot = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
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

    syncthing = {
      enable = true;
    };
    
    udiskie = {
      enable = true;
      tray = "always";
    };

    screen-locker = {
      enable = true;
      inactiveInterval = 30;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000";
      xautolock.extraOptions = [ "Xautolock.killer: systemctl suspend" ];
    };

  };
}
