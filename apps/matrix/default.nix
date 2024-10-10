{
  config,
  lib,
  pkgs,
  ...
}:
let
  pkg =
    (import (
      pkgs.fetchFromGitLab {
        owner = "famedly";
        repo = "conduit";
        rev = "b11855e7a1fc00074a13f9d1b9ab04462931332f";
        sha256 = "sha256-hqjRGQIBmiWpQPhvix8L5rcxeuJ2z0KZS6A6RbmTB/o=";
      }
    )).outputs.packages.x86_64-linux.default;
in
{
  services.matrix-conduit = {
    enable = true;
    # package = pkg;
    settings.global = {
      server_name = "greaka.de";
      enable_lightning_bolt = false;
      database_backend = "rocksdb";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8448 ];
  services.nginx.virtualHosts."greaka.de" = {
    forceSSL = true;
    useACMEHost = "greaka.de";
    listen =
      with lib;
      flatten (
        map (
          addr:
          map
            (port: {
              inherit addr port;
              ssl = port != 80;
            })
            [
              80
              443
              8448
            ]
        ) config.services.nginx.defaultListenAddresses
      );
    locations = {
      "/_matrix" = {
        proxyPass = "http://localhost:${toString config.services.matrix-conduit.settings.global.port}";
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
            },
            "org.matrix.msc3575.proxy": {
              "url": "https://greaka.de"
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
  backups = [ "/var/lib/matrix-conduit/*" ];
}
