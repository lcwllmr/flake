# helix text editor with only a few custom settings

{ pkgs, ... }:
{
  # TODO: build semi-automatic pipeline to get this for the latex i need
  #   - https://tex.stackexchange.com/questions/162385
  home.file.".config/helix/unicode-input/latex.toml".text = ''
    alpha = "α"
    betta = "β"
    gamma = "γ"
    fire = "🔥"
  '';

  programs.helix = {
    enable = true;
    extraPackages = with pkgs; [
      nixfmt-rfc-style
      nixd
      simple-completion-language-server
    ];
    languages = {
      language-server.scls = {
        command = "simple-completion-language-server";
        config = {
          max_completion_items = 100; # set max completion results len for each group: words, snippets, unicode-input
          feature_words = true; # enable completion by word
          feature_snippets = true; # enable snippets
          snippets_first = true; # completions will return before snippets by default
          snippets_inline_by_word_tail = false; # suggest snippets by WORD tail, for example text `xsq|` become `x^2|` when snippet `sq` has body `^2`
          feature_unicode_input = true; # enable "unicode input"
          feature_paths = false; # enable path completion
          feature_citations = false; # enable citation completion (only on `citation` feature enabled)
        };
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "nixfmt";
          };
          language-servers = [ { name = "nixd"; } ];
        }
        {
          name = "markdown";
          indent = {
            tab-width = 2;
            unit = "  ";
          };
          language-servers = [ "scls" ];
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
        file-picker = {
          hidden = false;
          git-ignore = true;
        };
      };
    };
  };
}
