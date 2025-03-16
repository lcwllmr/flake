# fish shell with vim bindings and neat, simple prompt

{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting

      fish_vi_key_bindings
      bind yy fish_clipboard_copy
      bind Y fish_clipboard_copy
      bind -M visual y fish_clipboard_copy
      bind -M default p fish_clipboard_paste
      set -g fish_vi_force_cursor
      set -g fish_cursor_default block
      set -g fish_cursor_insert line
      set -g fish_cursor_visual block
      set -g fish_cursor_replace_one underscore

      set -g __fish_git_prompt_showdirtystate 1
    '';
    shellAliases = {
      nix-shell = "nix-shell --run fish";
    };
    functions = {
      fish_prompt = {
        body = ''
          set promptParts (set_color -o brwhite) "| "

          if test -n "$IN_NIX_SHELL"
            set promptParts $promptParts (set_color green) "[nix-shell] "
          end

          set promptParts $promptParts (set_color normal)
          set promptParts $promptParts (prompt_pwd --full-length-dirs 1)
          set promptParts $promptParts (fish_git_prompt)
          set promptParts $promptParts (set_color -o brwhite) ' > '
          set promptParts $promptParts (set_color normal)

          string join "" -- $promptParts
        '';
      };
      fish_mode_prompt.body = "";
      fish_right_prompt.body = "";
    };
  };
}