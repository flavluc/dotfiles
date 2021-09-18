{ pkgs, config, ... }:

{
  programs.neovim = {
    enable = true;
    vimAlias = true;
  };
}
