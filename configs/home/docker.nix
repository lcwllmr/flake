{ self, pkgs, ... }:
{
  home.username = "lcwllmr";
  home.homeDirectory = "/home/lcwllmr";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  programs.git.enable = true;
  home.packages = [ pkgs.rclone ];

  imports = with self.homeModules; [
    fish helix
  ];
}