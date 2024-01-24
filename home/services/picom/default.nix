{ config, pkgs, ... }:

{
  services.picom = {
    enable = true;
    settings = {
        corner-radius = 15;
        xinerama-shadow-crop = true;
    };

    activeOpacity = 0.8;
    inactiveOpacity = 0.8;
    backend = "glx";
    opacityRules = [ "50:class_g = 'Alacritty'" ];

    shadowExclude = [
        "bounding_shaped && !rounded_corners"
    ];

    fade = true;
    fadeDelta = 10;
    vSync = true;
    };
}
