{ pkgs, lib, ... }:

let
  extra = ''
    ${pkgs.util-linux}/bin/setterm -blank 0 -powersave off -powerdown 0
    ${pkgs.xorg.xset}/bin/xset s off
    ${pkgs.xcape}/bin/xcape -e "Hyper_L=Tab;Hyper_R=backslash"
  '';

  polybarOpts = ''
    ${pkgs.nitrogen}/bin/nitrogen --restore &
    ${pkgs.pasystray}/bin/pasystray &
    ${pkgs.blueman}/bin/blueman-applet &
    ${pkgs.gnome3.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator &
  '';

  fcitxOpts = ''
    export XMODIFIERS="@im=fcitx"
    export XMODIFIER="@im=fcitx"
    export GTK_IM_MODULE="fcitx"
    export QT_IM_MODULE="fcitx"
    fcitx &
  '';
in
{
  xresources.properties = {
    "Xft.dpi" = 96;
    "Xft.autohint" = 0;
    "Xft.hintstyle" = "hintfull";
    "Xft.hinting" = 1;
    "Xft.antialias" = 1;
    "Xft.rgba" = "rgb";
  };


  xsession = {
    enable = true;

    pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 32;
    };

    initExtra = extra + polybarOpts + fcitxOpts;

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = hp: [
        hp.dbus
        hp.monad-logger
      ];
      config = ./config.hs;
    };
  };
}
