{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.home-manager.flakeModules.home-manager
      ];
      systems = [ "x86_64-linux" ];
      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-tree;
          apps.testvm = import ./apps/testvm.nix { pkgs = pkgs; };
        };
      flake = {
        nixosModules = {
          tscloud = import ./modules/nixos/tscloud;
        };
        nixosConfigurations = {
          testvm = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
              ./configs/nixos/testvm.nix
            ];
          };
        };
        homeModules = {
          git = import ./modules/home/git.nix;
          fish = import ./modules/home/fish.nix;
          tmux = import ./modules/home/tmux.nix;
          ssh = import ./modules/home/ssh.nix;
          helix = import ./modules/home/helix.nix;
        };
        homeConfigurations = {
          t490s = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = {
              inputs = inputs;
            };
            modules = [
              ./configs/home/t490s.nix
            ];
          };
        };
      };
    };
}
