{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
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
    languages = {
      language-server.ruff = with pkgs; {
        command = "${ruff}/bin/ruff";
        args = ["server"];
      };
      language = [
        {
          name = "python";
          language-servers = ["ruff"];
          auto-format = true;
        }
      ];
    };
  };
}
