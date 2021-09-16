{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.username = "fuyu";
  home.homeDirectory = "/home/fuyu";

  imports = [
      ./dev.nix
  ];

  home.packages = with pkgs; [
    # cli and terminal
    ripgrep
    wget
    curl
    zip
    unzip
    unrar
    p7zip
    ripgrep
    fish
    htop
    neofetch
    xdotool
    xorg.xkill
    xorg.xrandr
    # gui programs
    pavucontrol
    firefox
    google-chrome
    dolphin
    arandr
    tdesktop
    discord
    spotify
    anki
    zathura
    qbittorrent
    vlc
    calibre
    mcomix3
    gparted
    woeusb
    flameshot
    # window managers
    xmobar
    feh
    picom
    dmenu
    # systray
    volumeicon
    trayer
    # fonts
    nerdfonts
    # rice
    pywal
    # themes
    gtk-engine-murrine
    gtk_engines
    breeze-qt5
    breeze-gtk
    lxappearance
    qt5ct
  ];
}
