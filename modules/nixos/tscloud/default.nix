{ pkgs, lib, config, ... }:
with lib;
let
    cfg = config.services.tscloud;
in
{
  options.services.tscloud = {
    enable = mkEnableOption "Enable Tailscale-centric cloud server";
    user = mkOption {
      type = types.str;
      default = "root";
      description = "User that runs all Docker containers and owns all files. If not root, must be part of the `docker` group.";
    };
    driveDirectory = mkOption {
      type = types.str;
      default = "/drive";
      description = "Directory for all user data.";
    };
    stateDirectory = mkOption {
      type = types.str;
      default = "/var/lib/tscloud";
      description = "Directory for files needed by the various services.";
    };
    tailscaleAuthkeyFile = mkOption {
      type = types.str;
      description = "Path to a file containing a valid Tailscale authkey.";
    };

    filebrowser = {
      enable = mkEnableOption "Enable Filebrowser service for managing files with a clean web UI.";
      port = mkOption {
        type = types.port;
        default = 10101;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      [ { assertion = cfg.user == "root" || (builtins.elem "docker" config.users.users.${cfg.user}.extraGroups);
          message = "tscloud user must either be root or member of the docker group";
        }
      ];
  
    systemd.tmpfiles.rules = [
      "d ${cfg.driveDirectory} 0755 ${cfg.user} - - -"
      "d ${cfg.stateDirectory} 0755 ${cfg.user} - - -"
    ];
  };

  imports = [
    ./filebrowser.nix
  ];
}
