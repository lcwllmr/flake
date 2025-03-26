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
        # NOTE: these don't seem to work currently. getting download errors. gotta investigate
        #hardware.graphics.extraPackages = with pkgs; [
        #  # these are supported since broadwell (which i7-5600U is)
        #  intel-media-driver
        #  intel-ocl
        #  intel-vaapi-driver
        #];
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
        services.xserver.enable = true;
        services.xserver.displayManager.gdm.enable = true;
        services.xserver.desktopManager.gnome.enable = true;
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
        ];

        home-manager.users.lcwllmr.dconf = {
          enable = true;
          settings = {
            "org/gnome/desktop/interface".color-scheme = "prefer-dark";
          };
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
