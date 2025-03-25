{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    inputs.home-manager.nixosModules.home-manager
    inputs.self.nixosModules.core
    (
      { pkgs, ... }:
      {
        # kernel modules
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

        # some hardware settings from gh:NixOS/nixos-hardware
        hardware.enableAllFirmware = true;
        hardware.cpu.intel.updateMicrocode = true;
        hardware.graphics.enable = true;
        hardware.graphics.extraPackages = with pkgs; [
          # these are supported since broadwell (which i7-5600U is)
          intel-media-driver
          intel-ocl
          intel-vaapi-driver
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

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.lcwllmr = {
          home.username = "lcwllmr";
          home.homeDirectory = "/home/lcwllmr";
          home.stateVersion = "24.11";
          programs.home-manager.enable = true;
          imports = with inputs.self.homeModules; [
            fish
            helix
          ];
        };
      }
    )
  ];
}
