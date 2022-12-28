{ config, ... }:
let
  domain = "greaka.de";
  fullDomain = "bw.${domain}";
  backupDir = "/tmp/vw-backup";
  cfg = config.services.vaultwarden.config;
in {
  services = {
    vaultwarden = {
      enable = true;

      backupDir = backupDir;

      config = {
        rocketAddress = "0.0.0.0";
        rocketPort = 8881;

        websocketEnabled = true;
        websocketAddress = "0.0.0.0";
        websocketPort = 3012;

        domain = "https://${fullDomain}";
        signupsAllowed = false;
      };

      environmentFile = "/run/keys/vaultwarden";
    };

    nginx.virtualHosts."${fullDomain}" = {
      forceSSL = true;
      useACMEHost = domain;

      locations = {
        "/".proxyPass = "http://localhost:${toString cfg.rocketPort}";

        "/notifications/hub" = {
          proxyPass = "http://localhost:${toString cfg.websocketPort}";
          proxyWebsockets = true;
        };

        "/notifications/hub/negotiate".proxyPass =
          "http://localhost:${toString cfg.rocketPort}";
      };
    };
  };

  alerts = [ "vaultwarden" ];
  backups = [ backupDir ];

  keys."vaultwarden".user = "vaultwarden";
}
