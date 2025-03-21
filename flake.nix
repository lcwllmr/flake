{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ self, withSystem, ... }: {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.home-manager.flakeModules.home-manager
      ];
      flake = {
        nixosModules = {
          core = import ./modules/nixos/core { inherit inputs; };
        };
        homeModules = {
          fish = import ./modules/home/fish.nix;
          helix = import ./modules/home/helix.nix;
        };
        homeConfigurations = {
          docker = withSystem "x86_64-linux" (ctx@{ pkgs, ... }:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit self;
              };
              modules = [
                ./configs/home/docker.nix
              ];
            });
        };
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        { pkgs, ... }:
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.nixfmt.package = pkgs.nixfmt-rfc-style;
          };
        };
    });
}
