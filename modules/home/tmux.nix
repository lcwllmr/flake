{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    mouse = true;
    disableConfirmationPrompt = true;
    escapeTime = 1;
    extraConfig = ''
      # split panes using | and -
      bind \\ split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # fast pane switching with Alt and vim keys
      bind -n M-h select-pane -L
      bind -n M-l select-pane -R
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D
    '';
  };
}
