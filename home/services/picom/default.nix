{ config, pkgs, ... }:

{
  services.picom = {
    enable = true;
    settings = {
        corner-radius = 10;
        crop-shadow-to-monitor = true;  # renamed from xinerama-shadow-crop
    };

    shadowExclude = [
        "bounding_shaped && !rounded_corners"
    ];
    };
}
