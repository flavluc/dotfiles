{ pkgs, config, ... }:

{
  home.sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
  home.sessionVariables = {
      DOOMDIR = "${config.xdg.configHome}/doom-config";
      DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
    };

  xdg.configFile = {
    "doom-config/config.el".text = "…";
    "doom-config/init.el".text = "…";
    "doom-config/packages.el".text = "…";
    "emacs" = {
      source = builtins.fetchGit {
        url = "https://github.com/hlissner/doom-emacs";
        ref = "develop";
        rev = "2c5cc752ff372745ae805312d3918e72ed620591";
      };
      onChange = "${pkgs.writeShellScript "doom-change" ''
        export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
        export DOOMLOCALDIR="${config.home.sessionVariables.DOOMLOCALDIR}"
        if [ ! -d "$DOOMLOCALDIR" ]; then
          ${config.xdg.configHome}/emacs/bin/doom -y install
        else
          ${config.xdg.configHome}/emacs/bin/doom -y sync -u
        fi
      ''}";
    };
  };

  programs.emacs.enable = true;

  services.emacs = {
    enable = true;
    client.enable = true;
    socketActivation.enable = true;
  };
}
