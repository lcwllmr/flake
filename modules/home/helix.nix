{ pkgs, ... }:
{
  home.packages = with pkgs; [
    typst
    tinymist
  ];

  programs.helix = {
    enable = true;
    settings = {
      editor = {
        line-number = "relative";
        soft-wrap.enable = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        file-picker = {
          hidden = false;
          git-ignore = true;
        };
      };
    };
    languages = {
      language-server = {
        ruff = with pkgs; {
          command = "${ruff}/bin/ruff";
          args = ["server"];
        };
        tinymist = {
          command = "tinymist";
          config = {
            preview.background.enabled = true;
            preview.background.args = [
              "--data-plane-host=127.0.0.1:23635"
              "--invert-colors=never"
              "--open"
            ];
          };
        };
      };
      language = [
        {
          name = "python";
          language-servers = [ "ruff" ];
          auto-format = true;
        }
        {
          name = "typst";
          language-servers = [ "tinymist" ];
        }
      ];
    };
  };
}
