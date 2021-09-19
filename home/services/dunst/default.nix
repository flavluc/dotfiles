{ config, pkgs, ... }:

let
  colors = import ../../themes/colors.nix;
in
{
  services.dunst = {
    enable = true;
    settings = with colors.scheme.helios; {
      global = {
        monitor = 0;
        geometry = "500x100-50+65";
        shrink = "yes";
        padding = 10;
        horizontal_padding = 10;
        frame_width = 0;
        frame_color = "${base00}";
        separator_color = "frame";
        font = "JetBrainsMono Nerd Font 8";
        line_height = 4;
        idle_threshold = 120;
        markup = "full";
        format = ''<b>%s</b>\n%b'';
        alignment = "left";
        vertical_alignment = "center";
        icon_position = "left";
        word_wrap = "yes";
        ignore_newline = "no";
        show_indicators = "yes";
        sort = true;
        stack_duplicates = true;
        startup_notification = false;
        hide_duplicate_count = true;
      };
      urgency_low = {
        background = "#${base05}";
        forefround = "#${base00}";
        timeout = 2;
      };
      urgency_normal = {
        background = "#${base05}";
        forefround = "#${base00}";
        timeout = 2;
      };
      urgency_critical = {
        background = "#${base0A}";
        forefrond = "#${base0D}";
        frame_color = "#${base08}";
        timeout = 5;
      };
    };
  };
}
