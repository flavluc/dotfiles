{ config, pkgs, ... }:

{
  services.picom = {
    enable = true;
    extraOptions = ''
        corner-radius = 15;
        xinerama-shadow-crop = true;
    '';
    experimentalBackends = true;

    shadowExclude = [
        "bounding_shaped && !rounded_corners"
    ];

    fade = true;
    fadeDelta = 10;
    vSync = true;
    package = pkgs.picom.overrideAttrs(o: {
        src = pkgs.fetchFromGitHub {
        repo = "picom";
        owner = "ibhagwan";
        rev = "44b4970f70d6b23759a61a2b94d9bfb4351b41b1";
        sha256 = "0iff4bwpc00xbjad0m000midslgx12aihs33mdvfckr75r114ylh";
        };
    });
    };
}
