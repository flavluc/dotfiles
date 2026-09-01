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
      kubectl completion fish | source
    '';
    shellAliases = {
      cat  = "bat";
      dc   = "docker-compose";
      dps  = "docker-compose ps";
      dcd  = "docker-compose down --remove-orphans";
      drm  = "docker images -a -q | xargs docker rmi -f";
      du   = "ncdu --color dark -rr -x";
      k    = "kubectl";
      ls   = "eza";
      ll   = "ls -a";
      ".." = "cd ..";
      ping = "prettyping";
      tree = "eza -T";
    };
    shellInit = fishConfig;

    functions = {
      # Port-forwards a private Tamborine service through the bastion host via
      # SSM. The service name must also resolve to 127.0.0.1 (see
      # networking.hosts in hosts/common.nix) so the TLS cert still validates.
      tunnel = {
        description = "SSM port-forward to a private tamborine service";
        body = ''
          set -l service $argv[1]
          set -l port $argv[2]

          switch "$service"
            case grafana
              test -n "$port"; or set port 8080
            case minio
              # 8081 so grafana and minio can be tunnelled at the same time
              test -n "$port"; or set port 8081
            case '*'
              echo "usage: tunnel (grafana|minio) [local-port]" >&2
              return 1
          end

          set -l host "$service.tamborine.app"

          # AWS_PROFILE wins when the shell already has one exported
          set -l profile
          if not set -q AWS_PROFILE
            set profile --profile sso-dev
          end

          set -l bastion (aws $profile ec2 describe-instances \
            --filters "Name=tag:Name,Values=bastion-host" \
                      "Name=instance-state-name,Values=running" \
            --query "Reservations[*].Instances[*].InstanceId" --output text)

          if test -z "$bastion"
            echo "tunnel: no running bastion-host found, try: aws sso login --profile sso-dev" >&2
            return 1
          end

          echo "tunnel: https://$host:$port via $bastion"

          aws $profile ssm start-session --target $bastion \
            --document-name AWS-StartPortForwardingSessionToRemoteHost \
            --parameters "{\"host\":[\"$host\"],\"portNumber\":[\"443\"],\"localPortNumber\":[\"$port\"]}"
        '';
      };
    };
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
