{ config, lib, ... }:
with lib;
let
  d = config.core.services.docker;
  user = config.core.user;
  mainUserNotRoot = user != "root";
in
{
  config = mkIf d.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = d.boot;
      rootless.enable = mkIf mainUserNotRoot true;
      rootless.setSocketVariable = mkIf mainUserNotRoot true;
    };

    users.users.${user}.extraGroups = mkIf mainUserNotRoot [
      "docker"
    ];

    core.persist = {
      sysDirs = [
        "/var/lib/docker"

        # not necessary; see https://github.com/moby/moby/issues/41672
        #"/opt/containerd"
      ];
      userDirs = mkIf mainUserNotRoot [
        ".local/share/docker"
      ];
    };
  };
}
