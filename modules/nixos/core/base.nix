{ config, lib, ... }:
with lib;
let
  c = config.core;
  s = c.services.ssh;
  userNotRoot = c.user != "root";
in
{
  assertions = [
    {
      assertion = (c.hashedPassword == null) || (builtins.stringLength c.hashedPassword > 0);
      message = "Don't set `core.hashedPassword` to an empty string. Use `null` (which is also the default value).";
    }
    {
      assertion = (c.hashedPassword != null) || s.enable;
      message = "Either provide `core.hashedPassword` or switch on `core.services.ssh.enable`. Otherwise you can't log into the system.";
    }
  ];

  networking.hostName = c.hostName;
  system.stateVersion = c.stateVersion;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = mkIf userNotRoot [ "@wheel" ];
  };

  users.users.${c.user} = {
    isNormalUser = mkIf userNotRoot true;
    hashedPassword = mkIf (c.hashedPassword != "") c.hashedPassword;
    extraGroups = mkIf userNotRoot [ "wheel" ];
  };

  # only use DHCP if NetworkManager is not present
  networking.useDHCP = mkIf (!config.core.services.networkManager) true;

  core.persist = {
    userDirs = [
      ".ssh"
    ];
    sysDirs = [
      "/var/log"
      "/var/lib/nixos"
    ];
  };

}
