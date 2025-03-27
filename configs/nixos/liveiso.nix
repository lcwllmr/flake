{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    inputs.home-manager.nixosModules.home-manager
    (
      { modulesPath, pkgs, ... }:
      {
        imports = [
          (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
        ];

        # use another font to keep things fun
        console.font = "Lat2-Terminus16";

        # speed up builds by trading off compression
        isoImage.squashfsCompression = "gzip -Xcompression-level 1";

        # NetworkManager instead of wpa_supplicant
        networking.wireless.enable = false;
        networking.networkmanager.enable = true;
        users.users.nixos.extraGroups = [ "networkmanager" ];

        # enable flakes out-of-the-box
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        # pre-install some utitlities for local installation
        environment.systemPackages = with pkgs; [
          disko
        ];

        # pull in some of my home-manager modules to feel homey
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.nixos = {
          home.username = "nixos";
          home.homeDirectory = "/home/nixos";
          home.stateVersion = "24.11";
          imports = with inputs.self.homeModules; [
            git
            helix
          ];
        };
      }
    )
  ];
}
