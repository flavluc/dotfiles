{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };

  boot.supportedFilesystems = [ "ntfs" ];

  boot.loader.grub = {
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

  networking.hostName = "insp-nix";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";

  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  services.xserver.enable = true;

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.defaultSession = "none+xmonad";
  services.xserver.windowManager = {
    xmonad.enable = true;
    xmonad.enableContribAndExtras = true;
    xmonad.extraPackages = hpkgs: [
      hpkgs.xmonad
      hpkgs.xmonad-contrib
      hpkgs.xmonad-extras
    ];
  };
  
  services.xserver.layout = "br";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.libinput.enable = true;

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  users.users.fuyu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };

  environment.variables.QT_QPA_PLATFORMTHEME = "qt5ct";

  environment.systemPackages = with pkgs; [
    # cli and terminal
    ripgrep
    wget
    curl
    zip
    unzip
    unrar
    p7zip
    ripgrep
    git
    alacritty
    fish
    htop
    neofetch
    xdotool
    xorg.xkill
    xorg.xrandr
    # text editors
    vim
    ((emacsPackagesNgGen emacs).emacsWithPackages (epkgs: [
      epkgs.vterm
    ]))
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
    # dev
    gcc
    cmake
    gnumake
    libtool
    libvterm
    clang
    python3
    ghc
    stack
    nodejs
    yarn
    elixir
    rustc
    rustup
    cargo
    zola
    # themes
    # arc-theme
    gtk-engine-murrine
    gtk_engines
    breeze-qt5
    breeze-gtk
    lxappearance
    qt5ct
  ];

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "SourceCodePro" "Ubuntu" "Mononoki" ]; })
    carlito
    dejavu_fonts
    ipafont
    kochi-substitute
    source-code-pro
    ttf_bitstream_vera
    emacs-all-the-icons-fonts
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVu Sans Mono"
      "IPAGothic"
    ];
    sansSerif = [
      "DejaVu Sans"
      "IPAPGothic"
    ];
    serif = [
      "DejaVu Serif"
      "IPAPMincho"
    ];
  };

  i18n.inputMethod.enabled = "fcitx";

  i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "21.05";
}
