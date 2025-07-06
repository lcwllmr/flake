{
  espPartition =
  {
    size = "500M";
    type = "EF00";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
      mountOptions = [ "umask=0077" ];
    };
  };

  simpleExt4RootPartition = {
    type = "filesystem";
    format = "ext4";
    mountpoint = "/";
  };

  btrfsSubvolume = name: mountpoint: {
    mountpoint = mountpoint;
    mountOptions = [
      "subvol=${name}"
      "compress=zstd"
      "noatime"
    ];
  };

  swapFile = size: {
    mountpoint = "/swap";
    swap.swapfile.size = size;
  };

  btrfsOnLuksRootPartition = subvolumes:
  {
    name = "nixos";
    size = "100%";
    content = {
      type = "luks";
      name = "crypted";
      extraOpenArgs = [
        "--allow-discards"
        "--perf-no_read_workqueue"
        "--perf-no_write_workqueue"
      ];
      passwordFile = "/tmp/keyfile";
      settings.allowDiscards = true;
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = subvolumes;
      };
    };
  };
}
