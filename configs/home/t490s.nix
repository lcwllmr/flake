{ pkgs, ... }:
{
  home.username = "lcwllmr";
  home.homeDirectory = "/home/lcwllmr";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    uv
  ];

  imports = [
    ../../modules/home/fish.nix
    ../../modules/home/git.nix
    ../../modules/home/ssh.nix
    ../../modules/home/tmux.nix
  ];
}
