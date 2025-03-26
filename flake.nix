{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
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

      apps = eachSystem (pkgs: {
        unmelt = {
          type = "app";
          program = let
            script = pkgs.writeShellScriptBin "unmelt" ''
              echo "Type the melt seed phrase and then enter EOF (via Ctrl+D)." \
                && mkdir -p ~/.ssh \
                && ${pkgs.melt}/bin/melt restore ~/.ssh/id_ed25519 \
                && echo "SSH key has been written to ~/.ssh. Public key for validation:" \
                && cat ~/.ssh/id_ed25519.pub
            '';
          in "${script}/bin/unmelt";
        };
      });

      nixosModules = {
        core = import ./modules/nixos/core { inherit inputs; };
      };

      homeModules = {
        git = import ./modules/home/git.nix;
        fish = import ./modules/home/fish.nix;
        helix = import ./modules/home/helix.nix;
      };

      nixosConfigurations = {
        liveiso = import ./configs/nixos/liveiso.nix { inherit inputs; };
        t450s = import ./configs/nixos/t450s.nix { inherit inputs; };
      };
    };
}
