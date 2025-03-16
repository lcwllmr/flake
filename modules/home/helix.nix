# helix text editor with only a few custom settings

{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    extraPackages = with pkgs; [
      nixfmt-rfc-style nixd
    ];
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = { command = "nixfmt"; };
          language-servers = [ { name = "nixd"; } ];
        }
        {
          name = "markdown";
          indent = { tab-width = 2; unit = "  "; };
        }
      ];
    };
    settings = {
      editor = {
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
    };
  };
}