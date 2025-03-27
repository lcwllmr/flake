{
  config,
  lib,
  ...
}:
with lib;
let
  u = config.core.user;
in
{
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users."${u}" = {
      home.username = u;
      home.homeDirectory = "/home/${u}";
      home.stateVersion = config.core.stateVersion;
      programs.home-manager.enable = true;

      imports = [
        {
          # add options to that allow home modules to add persistent paths
          options.persist = with types; {
            dirs = mkOption {
              description = "Same as `core.persist.userDirs` but accessible from within home modules.";
              type = listOf anything;
              default = [ ];
            };
            files = mkOption {
              description = "Same as `core.persist.userFiles` but accessible from within home modules.";
              type = listOf anything;
              default = [ ];
            };
          };
        }
      ];
    };
  };
}
