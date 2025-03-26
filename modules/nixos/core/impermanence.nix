{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  b = config.core.bootDisk;
  p = config.core.persist;
  user = config.core.user;
  homeDir = if user == "root" then "/root" else "/home/${user}";
  userNotRoot = user != "root";
in
{
  config = mkIf b.impermanent {
    fileSystems."/persist".neededForBoot = true;
    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;
      directories = p.sysDirs;
      files = p.sysFiles;
      users.${config.core.user} = {
        home = homeDir;
        directories = p.userDirs;
        files = p.userFiles;
      };
    };

    # purge and re-new root partition on boot
    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.tpm2.enable = mkIf b.encrypted true;
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root subvolume to a pristine state";
      wantedBy = [
        "initrd.target"
      ];
      after = mkIf b.encrypted [
        # TODO: what happens on non-encrypted systems?
        "systemd-cryptsetup@enc.service"
      ];
      before = [
        "sysroot.mount"
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        delete_subvol_rec() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvol_rec "/mnt/$i"
          done
          btrfs subvolume delete "$1"
        }

        mkdir -p /mnt
        mount -o subvol=/ /dev/mapper/${if b.encrypted then "crypted" else "nixos"} /mnt
        delete_subvol_rec /mnt/root
        btrfs subvolume create /mnt/root
        umount /mnt
      '';
    };

    # otherwise you'd see the lecture after each reboot
    security.sudo.extraConfig = mkIf userNotRoot ''
      Defaults lecture = never
    '';

    # Script to find all files that will be discarded by the next boot.
    # Run with sudo so you don't get permission errors.
    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "impermanence-ls";
        text =
          let
            map = builtins.map;
            getFileName = x: if (builtins.isString x) then x else builtins.getAttr "file" x;
            getDirName = x: if (builtins.isString x) then x else builtins.getAttr "directory" x;
            appendWildcard = path: path + "/*";
            prependHome = path: "${homeDir}/" + path;
            sysFiles = map getFileName p.sysFiles;
            sysDirs = map appendWildcard (map getDirName p.sysDirs);
            userFiles = map prependHome (map getFileName p.userFiles);
            userDirs = map prependHome (map appendWildcard (map getDirName p.userDirs));
            extraExcludedDirs = map appendWildcard [
              "/boot"
              "/nix"
              "/persist"
              "/swap"

              # the following directories are all for runtime data
              "/proc"
              "/sys"
              "/run"
              "/tmp"
              "/dev/shm"
            ];
            allExcludedPaths = sysDirs ++ userDirs ++ extraExcludedDirs ++ sysFiles ++ userFiles;
            addQuotationMarks = item: "\"" + item + "\"";
          in
          ''
            # transform all exclusion paths into arguments for 'find'
            exclude_paths=(${builtins.concatStringsSep " " (map addQuotationMarks allExcludedPaths)})
            exclude_args=()
            for path in "''${exclude_paths[@]}"; do
              exclude_args+=("-path" "$path" "-prune" "-o")

              # uncomment the next line for debugging
              #echo "''${path}"
            done

            # note that the '-type f' excludes symlinks (i.e. nix store won't interfere)
            find / \
              "''${exclude_args[@]}" \
              -type f \
              -print
          '';
      })
    ];
  };
}
