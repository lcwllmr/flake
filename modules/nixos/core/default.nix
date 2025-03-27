{ inputs }:
{ config, lib, ... }:
{
  options.core =
    with lib;
    with lib.types;
    {
      hostName = mkOption {
        description = "System host name. Alias for `networking.hostName`.";
        type = str;
      };
      stateVersion = mkOption {
        description = "Nixpkgs state version.";
        type = str;

      };
      user = mkOption {
        description = "Primary user of the system. If not `root`, then they will be added to group `wheel` and Nix trusted users.";
        type = str;
      };
      hashedPassword = mkOption {
        description = "Hashed password (as produced by `mkpasswd`). If `null`, then `core.services.ssh.enable` must be switched on.";
        type = nullOr str;
        default = null;
      };

      bootDisk = {
        device = mkOption {
          description = "Block device that shall be used as boot disk. `disko` will install an EFI system partition and a BTRFS partition (possibly encrypted).";
          example = "/dev/sda";
          type = str;
        };
        swapSizeMb = mkOption {
          description = "Size of the swap file in MB.";
          type = ints.positive;
        };
        encrypted = mkOption {
          description = "Whether the root Btrfs partition should be encrypted using LUKS. Password will be asked during disko installation.";
          type = bool;
          default = false;
        };
        impermanent = mkOption {
          description = ''
            Make the system impermanent. The root partition will be wiped on reboot. Directories and files that should be persisted between boots must be explicitly declared using the list options in `core.persist`. Essential directories and `~/.ssh` are added by default.

                      Enabling this will also install a scritp `impermanence-ls` that lists all files on the system that are currently non-persistent. Useful for finding the right directories.'';
          type = bool;
          default = false;
        };
      };

      persist = {
        sysDirs = mkOption {
          description = "List of full paths of directories to be persisted. Warning: targets will be wiped on first nixos-rebuild.";
          example = ''
            [
              "/var/www/html"
              { directory = "/etc/nixos"; user = "alice"; }
            ]
          '';
          type = listOf anything;
          default = [ ];
        };
        sysFiles = mkOption {
          description = "List of full paths of files to be persisted. Will be automatically owned by `core.user`. Warning: targets will be wiped on first nixos-rebuild.";
          type = listOf anything;
          default = [ ];
        };
        userDirs = mkOption {
          description = "List of directories relative to `$HOME` to be persisted. Will be automatically owned by `core.user`. Warning: targets will be wiped on first nixos-rebuild.";
          example = ''
            [
              .cache
            ]
          '';
          type = listOf anything;
          default = [ ];
        };
        userFiles = mkOption {
          description = "List of files relative to `$HOME` to be persisted. Warning: targets will be wiped on first nixos-rebuild.";
          example = ''
            [
              .bash_history
            ]
          '';
          type = listOf anything;
          default = [ ];
        };
      };

      services = {
        ssh = {
          enable = mkOption {
            description = "Enable OpenSSH service on port 22 allowing only key-based authentification and only for `core.user`.";
            type = bool;
            default = false;
          };
          authorizedKeys = mkOption {
            description = "List of authorized SSH public keys for `core.user`.";
            type = listOf str;
            default = [ ];
          };
        };
        networkManager = mkOption {
          description = "Enable NetworkManager with iwd backend and persist state directories to remember connections.";
          type = bool;
          default = false;
        };
        docker = {
          enable = mkOption {
            description = "Enable Docker service on the system and persist state directories. If `core.mainUser` is not root, then this also enables rootless mode.";
            type = bool;
            default = false;
          };
          boot = mkOption {
            description = "Whether to launch Docker already at boot. Containers with `--restart=always` need this.";
            type = bool;
            default = false;
          };
        };
      };
    };

  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    ./base.nix
    ./boot-disk.nix
    ./impermanence.nix
    ./home-manager.nix
    ./services/openssh.nix
    ./services/network-manager.nix
    ./services/docker.nix
    (lib.mkAliasOptionModule
      [
        "core"
        "home"
      ]
      [
        "home-manager"
        "users"
        config.core.user
      ]
    )
  ];
}
