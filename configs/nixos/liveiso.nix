{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    (
      { modulesPath, pkgs, ... }:
      {
        imports = [
          (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
        ];

        # speed up builds by trading off compression
        isoImage.squashfsCompression = "gzip -Xcompression-level 1";

        # enable flakes out-of-the-box
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        # pre-install some utitlities for local installation
        environment.systemPackages = with pkgs; [
          disko
          helix
        ];
      }
    )
  ];
}
