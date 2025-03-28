{ lib, config, ... }:
with lib;
{
  config = mkIf config.core.apps.firefox {
    # Better touchpad, touchscreen and scrolling according to
    #   https://wiki.nixos.org/wiki/Firefox#Use_xinput2
    # I think this doesn't do anything on Gnome/Wayland though.
    environment.sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
    };

    # NOTE: For a hard-reset, just delete the following two directories
    #   rm -rf ~/.mozilla/firefox/* .cache/mozilla/firefox/*
    # Also necessary when changing settings for home-manager not to have
    # clashes with existing files.
    core.persist.userDirs = [
      ".mozilla/firefox"
      ".cache/mozilla/firefox"
    ];

    core.home.programs.firefox = {
      enable = true;

      # NOTE: I expect the following settings to break gradually
      # over time. Last tested with VERSION 136.0.2

      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;

        settings = {
          # All these settings can be found in about:config
          "browser.startup.homepage" = "about:blank";
          "browser.newtabpage.enabled" = false;
          "browser.translations.automaticallyPopup" = false;
          "browser.urlbar.shortcuts.bookmarks" = false;
          "browser.urlbar.shortcuts.history" = false;
          "browser.urlbar.shortcuts.tabs" = false;
          "browser.urlbar.sponsoredTopSites" = false;
          "browser.urlbar.suggest.addons" = false;
          "browser.urlbar.suggest.bookmark" = false;
          "browser.urlbar.suggest.calculator" = false;
          "browser.urlbar.suggest.clipboard" = false;
          "browser.urlbar.suggest.engines" = false;
          "browser.urlbar.suggest.fakespot" = false;
          "browser.urlbar.suggest.history" = false;
          "browser.urlbar.suggest.mdn" = false;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.pocket" = false;
          "browser.urlbar.suggest.quickactions" = false;
          "browser.urlbar.suggest.recentsearches" = false;
          "browser.urlbar.suggest.remotetab" = false;
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.urlbar.suggest.trending" = false;
          "browser.urlbar.suggest.weather" = false;
          "browser.urlbar.suggest.yelp" = false;

          # The following is a temporary fix for slowing down the
          # touchpad scroll speed on my laptops.
          "mousewheel.default.delta_multiplier_x" = 35;
          "mousewheel.default.delta_multiplier_y" = 35;
        };
      };

      # Policies are more powerful than profile settings. To see
      # more options, visit:
      #   https://github.com/mozilla/policy-templates
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "never";
        SearchBar = "unified";

        # For finding extension IDs: github:???/mozid
        ExtensionSettings = {
          "*" = {
            # disable manual installations
            installation_mode = "blocked";
          };

          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            default_area = "menupanel";
          };

          # Bitwarden password manager
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };

          # Raindrop bookmark manager
          "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/raindropio/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
        };
      };
    };
  };
}
