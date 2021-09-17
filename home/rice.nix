{ pkgs, ... }:

{
  home.packages = with pkgs; [
    feh
    dmenu
    pywal
  ];

  services.picom = {
    enable = true;
    activeOpacity = "0.90";
    blur = true;
    blurExclude = [
      "class_g = 'slop'"
    ];
    extraOptions = ''
      corner-radius = 0;
      blur-method = "dual_kawase";
      blur-strength = "10";
      xinerama-shadow-crop = true;
    '';
    experimentalBackends = true;

    shadowExclude = [
      "bounding_shaped && !rounded_corners"
    ];

    fade = true;
    fadeDelta = 5;
    vSync = true;
    opacityRule = [
      "70:class_g   = 'Firefox'"
      "70:class_g   = 'emacs'"
    ];
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
