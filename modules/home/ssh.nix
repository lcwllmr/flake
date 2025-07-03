{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      NoHostAuthenticationForLocalhost yes
    '';
  };
}
