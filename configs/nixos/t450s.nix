{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    inputs.home-manager.nixosModules.home-manager
    inputs.self.nixosModules.core
    (
      { pkgs, ... }:
      {
        # base stuff from nixos-generate-config
        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "usb_storage"
          "sd_mod"
        ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        # some hardware settings from gh:nixos-hardware for the t450s
        nixpkgs.config.allowUnfree = true;
        hardware.enableAllFirmware = true;
        hardware.cpu.intel.updateMicrocode = true;
        hardware.graphics.enable = true;
        hardware.graphics.extraPackages = with pkgs; [
          intel-media-driver
          # intel-vaapi-driver
        ];
        hardware.trackpoint.enable = true;
        hardware.trackpoint.emulateWheel = true;
        services.fstrim.enable = true;

        # software core
        core = {
          hostName = "t450s";
          stateVersion = "24.11";
          user = "lcwllmr";
          hashedPassword = "$y$j9T$e.jm9GbGrsIvCx4PQ6a4D1$4.9Q/qqYKm3KLSJpVNMgp3wwq0TuTNzIZSeySshSX//";
          bootDisk = {
            device = "/dev/sda";
            swapSizeMb = 8192;
            encrypted = true;
            impermanent = true;
          };
          services.networkManager = true;
        };

        # install quite minimal gnome
        services.xserver = {
          enable = true;
          desktopManager.gnome.enable = true;
          displayManager.gdm.enable = true;
          excludePackages = [ pkgs.xterm ];
        };

        services.displayManager = {
          autoLogin.enable = true;
          autoLogin.user = "lcwllmr";
        };

        environment.gnome.excludePackages = with pkgs; [
          gnome-tour
          gnome-user-docs
          gnome-software
          gnome-text-editor
          gnome-weather
          gnome-maps
          simple-scan
          orca
          geary
          gnome-disk-utility
          gnome-backgrounds
          baobab
          gnome-music
          gnome-shell-extensions
          gnome-clocks
          gnome-connections
          gnome-calculator
          totem
          gnome-logs
          gnome-font-viewer
          gnome-characters
          snapshot
          xdg-user-dirs
          xdg-user-dirs-gtk
        ];

        documentation.nixos.enable = false;

        home-manager.users.lcwllmr.dconf = {
          enable = true;
          settings = {
            "org/gnome/desktop/interface".color-scheme = "prefer-dark";
            "org/gnome/Console".audible-bell = false;
            "org/gnome/shell".favorite-apps = [
              "org.gnome.Epiphany.desktop"
              "org.gnome.Nautilus.desktop"
              "org.gnome.Console.desktop"
            ];
          };
        };

        home-manager.users.lcwllmr.xdg = {
          enable = true;
          userDirs.createDirectories = false;
        };

        # set fish as default shell for interactive sessions
        programs.bash = {
          interactiveShellInit = ''
            if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
            then
              shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
              exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
            fi
          '';
        };

        # temporary fixes until the core module becomes a bit smarter
        time.timeZone = "Europe/Oslo";
        console.font = "Lat2-Terminus16";

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.lcwllmr = {
          home.username = "lcwllmr";
          home.homeDirectory = "/home/lcwllmr";
          home.stateVersion = "24.11";
          programs.home-manager.enable = true;
          imports = with inputs.self.homeModules; [
            fish
            git
            helix
          ];
        };
      }
    )
  ];
}
