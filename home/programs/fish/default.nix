{ config, pkgs, lib, ... }:

let
  fzfConfig = ''
    set -x FZF_DEFAULT_OPTS "--preview='bat {} --color=always'" \n
    set -x SKIM_DEFAULT_COMMAND "rg --files || fd || find ."
  '';

  themeConfig = ''
    set -g theme_display_date no
    set -g theme_display_git_master_branch no
    set -g theme_nerd_fonts yes
    set -g theme_newline_cursor yes
    set -g theme_color_scheme solarized
  '';

  customPlugins = pkgs.callPackage ./plugins.nix {};

  fenv = {
    name = "foreign-env";
    src = pkgs.fishPlugins.foreign-env.src;
  };

  fishConfig = ''
    bind \t accept-autosuggestion
    set fish_greeting
  '' + fzfConfig + themeConfig;
in
{
  programs.fish = {
    enable = true;
    plugins = [ customPlugins.theme fenv ];
    interactiveShellInit = ''
      eval (direnv hook fish)
      any-nix-shell fish --info-right | source
    '';
    shellAliases = {
      cat  = "bat";
      dc   = "docker-compose";
      dps  = "docker-compose ps";
      dcd  = "docker-compose down --remove-orphans";
      drm  = "docker images -a -q | xargs docker rmi -f";
      du   = "ncdu --color dark -rr -x";
      ls   = "eza";
      ll   = "ls -a";
      ".." = "cd ..";
      ping = "prettyping";
      tree = "eza -T";
    };
    shellInit = fishConfig;
  };

  xdg.configFile."fish/functions/fish_prompt.fish".text = customPlugins.prompt;

  # Cleanup for the fish 3.x -> 4.x upgrade (NixOS 26.05). fish 4 migrates the
  # old universal fish_key_bindings variable by freezing it into a conf.d file;
  # when the old value was empty this yields "There is no fish_key_bindings
  # function called: ''" on every startup. Removing the frozen file and the
  # stale universal variable prevents/undoes that. Safe to drop once both
  # hosts have run it.
  home.activation.fishKeyBindingsMigrationCleanup =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run rm -f "$HOME/.config/fish/conf.d/fish_frozen_key_bindings.fish" \
                "$HOME/.config/fish/conf.d/fish_frozen_key_bindings.fish.bak"
      if [ -f "$HOME/.config/fish/fish_variables" ]; then
        run ${pkgs.gnused}/bin/sed -i '/^SETUVAR fish_key_bindings:/d' \
          "$HOME/.config/fish/fish_variables"
      fi
    '';
}
