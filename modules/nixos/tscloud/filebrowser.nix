{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.services.tscloud;
in
{
  config = mkIf (cfg.enable && cfg.filebrowser.enable) {
    systemd.services.tscloud-filebrowser = let
      serveConfig = pkgs.writeText "tscloud-filebrowser-serve.json" ''
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
                  "Proxy": "http://localhost:${builtins.toString cfg.filebrowser.port}"
                }
              }
            }
          }
        }
      '';
      composeFile = pkgs.writeText "tscloud-filebrowser-compose.yaml" ''
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
              - ${serveConfig}:/ts-serve-config.json
              - ${cfg.stateDirectory}/filebrowser/tailscale:/var/lib/tailscale
              - ${cfg.driveDirectory}:/drive
            devices:
              - /dev/net/tun:/dev/net/tun
            cap_add:
              - net_admin
            restart: unless-stopped
          filebrowser:
            image: filebrowser/filebrowser
            environment: # this seem to be undocumented as of right now
              - FB_NOAUTH=true
              - FB_PORT=${builtins.toString cfg.filebrowser.port}
              - FB_DATABASE=/filebrowser/state.db
              - FB_ROOT=/drive
            volumes:
              - ${cfg.stateDirectory}/filebrowser:/filebrowser
              - ${cfg.driveDirectory}:/drive
            depends_on:
              - tailscale
            network_mode: service:tailscale
      '';
      upCmd = pkgs.writeShellScriptBin "tscloud-filebrowser-service-up" ''
        mkdir -p ${cfg.stateDirectory}/filebrowser
        touch ${cfg.stateDirectory}/filebrowser/state.db
        mkdir -p ${cfg.stateDirectory}/filebrowser/tailscale
        export TS_AUTHKEY=''$(<${cfg.tailscaleAuthkeyFile})
        docker-compose -f ${composeFile} up
      '';
      downCmd = pkgs.writeShellScriptBin "tscloud-filebrowser-service-down" ''
        docker-compose -f ${composeFile} down
      '';
    in {
      after = ["docker.service" "docker.socket"];
      wantedBy = ["multi-user.target"];
      path = [ pkgs.docker-compose ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        ExecStart = "${upCmd}/bin/tscloud-filebrowser-service-up";
        ExecStop = "${downCmd}/bin/tscloud-filebrowser-service-down";
      };
    };
  };
}
