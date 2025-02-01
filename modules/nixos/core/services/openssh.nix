{ config, lib, ... }:
with lib;
let
  user = config.core.user;
  s = config.core.services.ssh;
in
{
  config = mkIf s.enable {
    assertions = [
      {
        assertion = builtins.length s.authorizedKeys > 0;
        message = "`core.services.ssh.authorizedKeys` must not be empty as key-based authentification is the only allowed way of logging in.";
      }
    ];

    users.users.${user}.openssh = {
      authorizedKeys.keys = s.authorizedKeys;
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.AllowUsers = [ user ];
      ports = [ 22 ];
    };
  };
}
