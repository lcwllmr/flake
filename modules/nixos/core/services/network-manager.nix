{ config, lib, ... }:
with lib;
let
  user = config.core.user;
  mainUserNotRoot = user != "root";
in
{
  config = mkIf config.core.services.networkManager {
    networking.networkmanager.enable = true;

    users.users.${user}.extraGroups = mkIf mainUserNotRoot [
      "networkmanager"
    ];

    core.persist.sysDirs = [
      "/etc/NetworkManager"
      "/var/lib/NetworkManager"
      # "/var/lib/iwd"
    ];
  };
}
