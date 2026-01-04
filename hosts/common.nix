# Common configuration shared between all hosts
{ config, pkgs, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Re-probe display outputs
  boot.kernelParams = [ "drm_kms_helper.poll=Y" ];

  # Networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Add an X11 session that runs the user's ~/.xsession (from Home Manager)
  services.xserver.displayManager.session = [
    {
      name = "xmonad";
      manage = "window";
      start = ''exec "$HOME"/.xsession'';
    }
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # MongoDB
  services.mongodb.enable = true;

  # Lock screen
  security.pam.services.i3lock = {};
  programs.i3lock = {
    enable = true;
    package = pkgs.i3lock-color;
  };

  # Docker
  virtualisation.docker.enable = true;

  # Fonts
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
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

  # Define a user account
  users.users.flavio = {
    isNormalUser = true;
    description = "flavio";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" ];
    packages = with pkgs; [];
  };

  # Install firefox
  programs.firefox.enable = true;

   nixpkgs.config.permittedInsecurePackages = [
              "mongodb-7.0.25"
              "electron-32.3.3" # Keep your other packages
            ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "flavio" ];
      experimental-features = [ "nix-command" "flakes" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    extraOptions = ''
      keep-outputs     = true
      keep-derivations = true
    '';
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    firefox
  ];

  # Syncthing ports
  networking.firewall.allowedTCPPorts = [ 22000 8384 ];
  networking.firewall.allowedUDPPorts = [ 21027 ];

  # Phone access
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # NixOS release version
  system.stateVersion = "25.05";
}
