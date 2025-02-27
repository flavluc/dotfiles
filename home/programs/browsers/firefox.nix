{ pkgs, ... }:

let
  userChrome = ''
    #webrtcIndicator {
      display: none;
    }
    #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
      opacity: 0;
      pointer-events: none;
    }
    #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
        visibility: collapse !important;
    }
    #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
      display: none;
    }
    .tab {
      margin-left: 1px;
      margin-right: 1px;
    }
  '';

  # ~/.mozilla/firefox/PROFILE_NAME/prefs.js | user.js
  settings = {
    "app.normandy.first_run" = false;
    "app.shield.optoutstudies.enabled" = false;

    "browser.contentblocking.category" = "standard"; # "strict"
    "browser.ctrlTab.recentlyUsedOrder" = false;

    "browser.download.useDownloadDir" = false;
    "browser.download.viewableInternally.typeWasRegistered.svg" = true;
    "browser.download.viewableInternally.typeWasRegistered.webp" = true;
    "browser.download.viewableInternally.typeWasRegistered.xml" = true;

    "browser.link.open_newwindow" = true;

    "browser.search.region" = "PL";
    "browser.search.widget.inNavBar" = true;

    "browser.shell.checkDefaultBrowser" = false;
    "browser.tabs.loadInBackground" = true;

    "distribution.searchplugins.defaultLocale" = "en-US";

    "doh-rollout.balrog-migration-done" = true;
    "doh-rollout.doneFirstRun" = true;

    "dom.forms.autocomplete.formautofill" = false;

    "general.autoScroll" = true;
    "general.useragent.locale" = "en-US";

    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    "extensions.extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    "extensions.update.enabled" = false;
    "extensions.webcompat.enable_picture_in_picture_overrides" = true;
    "extensions.webcompat.enable_shims" = true;
    "extensions.webcompat.perform_injections" = true;
    "extensions.webcompat.perform_ua_overrides" = true;

    # DPI settings
    "layout.css.devPixelsPerPx" = "1";

    "print.print_footerleft" = "";
    "print.print_footerright" = "";
    "print.print_headerleft" = "";
    "print.print_headerright" = "";

    "privacy.donottrackheader.enabled" = true;

    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  };
in
{
  programs.firefox = {
    enable = true;

    profiles = {
      default = {
        id = 0;
        settings = settings;
        userChrome = userChrome;
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          # bitwarden @TODO fix this after updating nur
          darkreader
          i-dont-care-about-cookies
          languagetool
          link-cleaner
          privacy-badger
          tab-session-manager
          # tree-style-tab @TODO fix this after updating nur
          ublock-origin
          unpaywall
          vimium
        ];
      };
    };
  };
}
