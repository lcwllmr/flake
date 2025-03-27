{ config, lib, ... }:
with lib;
let
  b = config.core.bootDisk;
in
{
  boot.loader = {
    timeout = mkForce 0; # disable generation selection
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;

    # NOTE: deploying via nixos-anywhere on Hetzner cloud
    # requires grub instead of systemd-boot. Maybe make this an
    # option at some point.
    #grub = {
    #  efiSupport = true;
    #  efiInstallAsRemovable = true;
    #};
  };

  disko.devices.disk.main =
    let
      #bootPartition = {
      #  name = "boot";
      #  size = "1M";
      #  type = "EF02";
      #};
      efiSystemPartition = {
        name = "esp";
        size = "500M";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = [ "umask=0077" ];
        };
      };

      mkSubvolume = name: mountpoint: {
        mountpoint = mountpoint;
        mountOptions = [
          "subvol=${name}"
          "compress=zstd"
          "noatime"
        ];
      };

      btrfsLayout = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = {
          "/root" = mkSubvolume "root" "/";
          "/nix" = mkIf b.impermanent (mkSubvolume "nix" "/nix");
          "/persist" = mkIf b.impermanent (mkSubvolume "persist" "/persist");
          "/workspaces" = mkSubvolume "workspaces" "/workspaces";
          "/swap" = {
            mountpoint = "/swap";
            swap.swapfile.size = "${builtins.toString b.swapSizeMb}M";
          };
        };
      };

      osPartitionContent =
        if !b.encrypted then
          btrfsLayout
        else
          {
            type = "luks";
            name = "crypted";
            extraOpenArgs = [
              "--allow-discards"
              "--perf-no_read_workqueue"
              "--perf-no_write_workqueue"
            ];
            content = btrfsLayout;
          };
    in
    {
      type = "disk";
      device = b.device;
      content = {
        type = "gpt";
        partitions = {
          #boot = bootPartition;
          esp = efiSystemPartition;
          nixos = {
            name = "nixos";
            size = "100%";
            content = osPartitionContent;
          };
        };
      };
    };
}
