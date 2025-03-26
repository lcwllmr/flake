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
        networking.interfaces.enp0s25.useDHCP = true;
        networking.interfaces.wlan0.useDHCP = true;

        # some hardware settings from gh:nixos-hardware for the t450s
        hardware.enableRedistributableFirmware = true;
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

        core.persist.userDirs = [ ".ssh" ];

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
