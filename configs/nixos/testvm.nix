{
  inputs,
  config,
  pkgs,
  modulesPath,
  ...
}:
let
  tools.disko = import ../../tools/disko.nix;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
  ];

  # hardware
  nixpkgs.hostPlatform = "x86_64-linux";
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";
    imageSize = "20G";
    imageName = "testvm";
    content = {
      type = "gpt";
      partitions = {
        esp = tools.disko.espPartition { };
        root = tools.disko.simpleExt4RootPartition;
      };
    };
  };
  fileSystems."/home/lcwllmr/flake" = {
    device = "flake";
    fsType = "9p";
    options = [
      "trans=virtio"
      "version=9p2000.L"
    ];
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  networking.useDHCP = true;

  # software
  networking.hostName = "testvm";
  system.stateVersion = config.system.nixos.release;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  services.openssh.enable = true;
  users.users.lcwllmr = {
    initialPassword = "hello";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjQwN0XxtdzGX6TgZhSj/D9oCCU2n2FGAYrWlip6ZtM"
    ];
  };

  security.polkit.enable = true;

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age.keyFile = "/home/lcwllmr/.config/sops/age/keys.txt";
    secrets.tsauthkey = { };
  };

  services.tailscale = {
    enable = true;
    authKeyFile = "/run/secrets/tsauthkey";
    extraUpFlags = [ "--ssh" ];
    extraDaemonFlags = [ "--state=mem:" ]; # ephemeral node
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.lcwllmr = {
    home.username = "lcwllmr";
    home.homeDirectory = "/home/lcwllmr";
    home.stateVersion = config.system.nixos.release;
    programs.home-manager.enable = true;

    imports = [
      inputs.self.homeModules.git
      inputs.self.homeModules.fish
    ];

    programs.helix = {
      enable = true;
      defaultEditor = true;
    };
  };
}
