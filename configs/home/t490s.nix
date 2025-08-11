{ pkgs, inputs, ... }:
{
  home.username = "lcwllmr";
  home.homeDirectory = "/home/lcwllmr";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    uv
  ];

  imports = with inputs.self.homeModules; [
    fish
    git
    ssh
    tmux
    helix
    direnv
  ];
}
