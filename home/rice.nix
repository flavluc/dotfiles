{ pkgs ... }:

{
  home.packages = with pkgs; [
    xmobar
    feh
    picom
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
      corner-radius = 10;
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
      "80:class_g   *?= 'Chromium-browser'"
      "80:class_g   *?= 'Firefox'"
      "80:class_g   *?= 'emacs'"
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
