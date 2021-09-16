{ pkgs, ... }:

{
  manual.manpages.enable = true;

  home.packages = with pkgs; [
    gcc
    cmake
    gnumake
    libtool
    libvterm
    python3
    ghc
    stack
    nodejs
    yarn
    elixir
    rustc
    cargo
    zola
  ];

  programs.git = {
    enable = true;

    userEmail = "flaviolc18@gmail.com";
    userName = "Flávio Lúcio";

    delta.enable = true;
    lfs.enable = true;

    aliases = {
      p = "push";
      s = "status";
      c = "commit";
      co = "checkout";
      aa = "add -p";
      st = "stash";
      br = "branch";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      background_opacity = 1;

      window = {
        dynamic_title = true;
        dynamic_padding = true;
        decorations = "full";
        dimensions = { lines = 0; columns = 0; };
        padding = { x = 5; y = 5; };
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      mouse = { hide_when_typing = true; };

      font = let
        fontname = "DejaVu Sans Mono";
      in
        {
          #font = let fontname = "Recursive Mono Linear Static"; in { # TODO fix this font with nerd font
          normal = { family = fontname; style = "Semibold"; };
          bold = { family = fontname; style = "Bold"; };
          italic = { family = fontname; style = "Semibold Italic"; };
          size = 14;
        };
      cursor.style = "Block";

      colors = {
        primary = {
          background = "0x24283b";
          foreground = "0xc0caf5";
        };
        normal = {
          black = "0x1D202F";
          red = "0xf7768e";
          green = "0x9ece6a";
          yellow = "0xe0af68";
          blue = "0x7aa2f7";
          magenta = "0xbb9af7";
          cyan = "0x7dcfff";
          white = "0xa9b1d6";
        };
        bright = {
          black = "0x414868";
          red = "0xf7768e";
          green = "0x9ece6a";
          yellow = "0xe0af68";
          blue = "0x7aa2f7";
          magenta = "0xbb9af7";
          cyan = "0x7dcfff";
          white = "0xc0caf5";
        };
        indexed_colors = [
          { index = 16; color = "0xff9e64"; }
          { index = 17; color = "0xdb4b4b"; }
        ];
      };
    };
  };
}
