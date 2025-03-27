{
  config,
  ...
}:
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
    };
  };
}
