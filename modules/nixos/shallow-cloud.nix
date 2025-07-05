{ pkgs, ... }:
{
  # TODO:
  #  - add some options (e.g. ports, host directories, secrets) to configure more transparently
  #  - check if tailscale and docker are available and user must be lingering and part of docker group
  #  - maybe split into multiple files

  systemd.tmpfiles.rules = [
    "d /drive 0755 lcwllmr - - -"
    "d /var/lib/cloud 0755 lcwllmr - - -"
  ];
  
  systemd.services.ts-filebrowser = let
    serveConfig = pkgs.writeText "ts-filebrowser-serve.json" ''
      {
        "TCP": {
          "443": {
            "HTTPS": true
          }
        },
        "Web": {
          "''${TS_CERT_DOMAIN}:443": {
            "Handlers": {
              "/": {
                "Proxy": "http://localhost:1234"
              }
            }
          }
        }
      }
    '';
    composeFile = pkgs.writeText "ts-filebrowser.yaml" ''
      services:
        tailscale:
          image: tailscale/tailscale:latest
          hostname: filebrowser
          environment:
            - TS_AUTHKEY
            - TS_AUTH_ONCE
            - TS_ACCEPT_DNS
            - TS_STATE_DIR=/var/lib/tailscale
            - TS_SERVE_CONFIG=/ts-serve-config.json
            - TS_EXTRA_ARGS=--ssh
          volumes:
            - tsfb-tailscale-state:/var/lib/tailscale
            - ${serveConfig}:/ts-serve-config.json
            - /cloud/drive:/drive
          devices:
            - /dev/net/tun:/dev/net/tun
          cap_add:
            - net_admin
          restart: unless-stopped
        filebrowser:
          image: filebrowser/filebrowser
          environment: # this seem to be undocumented as of right now
            - FB_NOAUTH=true
            - FB_PORT=1234
            - FB_DATABASE=/filebrowser/state.db
            - FB_ROOT=/drive
          volumes:
            - /var/lib/cloud/filebrowser:/filebrowser
            - /drive:/drive
          depends_on:
            - tailscale
          network_mode: service:tailscale
      volumes:
        tsfb-tailscale-state:
    '';
    upCmd = pkgs.writeShellScriptBin "ts-filebrowser-service-up" ''
      mkdir -p /var/lib/cloud/filebrowser
      touch /var/lib/cloud/filebrowser/state.db
      export TS_AUTHKEY=''$(</run/secrets/tsauthkey)
      docker-compose -f ${composeFile} up
    '';
    downCmd = pkgs.writeShellScriptBin "ts-filebrowser-service-down" ''
      docker-compose -f ${composeFile} down
    '';
  in {
    after = ["docker.service" "docker.socket"];
    wantedBy = ["multi-user.target"];
    path = [ pkgs.docker-compose ];
    serviceConfig = {
      Type = "simple";
      User = "lcwllmr";
      ExecStart = "${upCmd}/bin/ts-filebrowser-service-up";
      ExecStop = "${downCmd}/bin/ts-filebrowser-service-down";
    };
  };
}
