{ config, pkgs, ... }:
let
  domain = "greaka.de";
  fullDomain = "bw.${domain}";
  backupDir = "/tmp/vw-backup";
  cfg = config.services.vaultwarden.config;
  pkg = pkgs.callPackage ./package.nix { };
  webVaultPkg = pkgs.callPackage ./webvault.nix { };
in
{
  services = {
    vaultwarden = {
      enable = true;

      #package = pkg;
      #webVaultPackage = webVaultPkg;

      backupDir = backupDir;

      config = {
        rocketAddress = "0.0.0.0";
        rocketPort = 8881;

        domain = "https://${fullDomain}";
        signupsAllowed = false;
      };

      environmentFile = config.keys.vaultwarden.path;
    };

    nginx.virtualHosts."${fullDomain}" = {
      forceSSL = true;
      useACMEHost = domain;

      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.rocketPort}";
          proxyWebsockets = true;
        };
      };
    };
  };

  systemd.services.vaultwarden = {
    wants = [ "vaultwarden-key.service" ];
    after = [ "vaultwarden-key.service" ];
  };

  alerts = [ "vaultwarden" ];
  backups = [ backupDir ];

  keys."vaultwarden" = {
    services = [ "vaultwarden" ];
    user = "vaultwarden";
  };
}
