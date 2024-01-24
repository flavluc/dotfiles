{ config, pkgs, ... }:

{
  services.picom = {
    enable = true;
    settings = {
        corner-radius = 10;
        xinerama-shadow-crop = true;
    };

    shadowExclude = [
        "bounding_shaped && !rounded_corners"
    ];
    };
}
