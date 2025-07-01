{
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec fish $LOGIN_OPTION
      fi
    '';
  };
  
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

          if test -n "$SSH_CONNECTION"
            set promptParts $promptParts (set_color green) "[$USER@$hostname] "
          end

          if test -n "$IN_NIX_SHELL"
            set promptParts $promptParts (set_color red) "[nix-shell] "
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
