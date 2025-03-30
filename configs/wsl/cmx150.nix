{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    (
      { pkgs, ... }:
      {
        system.stateVersion = "24.11";
        wsl.enable = true;
        wsl.defaultUser = "lcwllmr";
        networking.hostName = "cmx150";

        nix.channel.enable = false;
        nix = {
          nixPath = [ "nixpkgs=${pkgs.path}" ];
        };

        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [ "@wheel" ];
        };

        programs.bash = {
          interactiveShellInit = ''
            if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
            then
              shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
              exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
            fi
          '';
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
            git
            helix
          ];
        };
      }
    )
  ];
}
