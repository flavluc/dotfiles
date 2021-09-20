{ config, pkgs, ... }:

{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        geometry = "500x100-50+65";
        shrink = "yes";
        padding = 10;
        horizontal_padding = 10;
        frame_width = 0;
        frame_color = "#1d2021";
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
        background = "#d5d5d5";
        forefround = "#1d2021";
        timeout = 2;
      };
      urgency_normal = {
        background = "#d5d5d5";
        forefround = "#1d2021";
        timeout = 2;
      };
      urgency_critical = {
        background = "#f19d1a";
        forefrond = "#1e8bac";
        frame_color = "#d72638";
        timeout = 5;
      };
    };
  };
}
