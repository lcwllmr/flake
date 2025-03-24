{
  inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
      ...
    }@inputs:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (
        pkgs:
        treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.nixfmt.package = pkgs.nixfmt-rfc-style;
        }
      );
    in
    {
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      nixosModules = {
        core = import ./modules/nixos/core { inherit inputs; };
      };

      homeModules = {
        fish = import ./modules/home/fish.nix;
        helix = import ./modules/home/helix.nix;
      };

      nixosConfigurations = {
        liveiso = import ./configs/nixos/liveiso.nix { inherit inputs; };
      };
    };
}
