{
  espPartition =
    {
      size ? "500M",
    }:
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

  luksPartition =
  {
    name,
    content,
  }:
  {
    type = "luks";
    name = name;
    extraOpenArgs = [
      "--allow-discards"
      "--perf-no_read_workqueue"
      "--perf-no_write_workqueue"
    ];
    passwordFile = "/tmp/keyfile";
    settings.allowDiscards = true;
    content = content;
  };
}
