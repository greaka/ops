{ config, lib, pkgs, ... }: {
  imports = [ ./override.nix ];

  services.matrix-conduit = {
    enable = true;
    settings.global = {
      server_name = "greaka.de";
      enable_lightning_bolt = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8448 ];
  services.nginx.virtualHosts."greaka.de" = {
    forceSSL = true;
    useACMEHost = "greaka.de";
    listen = with lib;
      flatten (map (addr:
        map (port: {
          inherit addr port;
          ssl = port != 80;
        }) [ 80 443 8448 ]) config.services.nginx.defaultListenAddresses);
    locations = {
      "/_matrix" = {
        proxyPass = "http://localhost:${
            toString config.services.matrix-conduit.settings.global.port
          }";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_buffering off;
        '';

        priority = 200;
      };

      "=/.well-known/matrix/server" = {
        alias = pkgs.writeText "well-known-matrix-server" ''
          {
            "m.server": "greaka.de"
          }
        '';

        extraConfig = ''
          default_type application/json;
        '';

        priority = 200;
      };

      "=/.well-known/matrix/client" = {
        alias = pkgs.writeText "well-known-matrix-client" ''
          {
            "m.homeserver": {
              "base_url": "https://greaka.de"
            }
          }
        '';

        extraConfig = ''
          default_type application/json;
          add_header Access-Control-Allow-Origin "*";
        '';

        priority = 200;
      };
    };
  };

  alerts = [ "conduit" ];
  backups = [ "/var/lib/matrix-conduit" ];
}
