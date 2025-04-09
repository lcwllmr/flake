{ inputs, ... }:
let
  system = "aarch64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      home.username = "lcwllmr";
      home.homeDirectory = "/home/lcwllmr";
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;

      programs.bash = {
        enable = true;
        bashrcExtra = ''
          fish
        '';
      };
    }
    inputs.self.homeModules.git
    inputs.self.homeModules.fish
  ];
}
