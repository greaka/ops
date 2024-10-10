{
  config,
  pkgs,
  lib,
  ...
}:
let
  pkg = pkgs.callPackage ./package.nix { };
in
{
  imports = [ ../grafana-agent ];

  services.redis.servers.wvwbot = {
    enable = true;
    port = 6379;
  };
  backups = [
    "/var/lib/redis-wvwbot/dump.rdb"
    "${config.services.postgresqlBackup.location}/wvwbot.sql.gz"
  ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    port = 6433;
    ensureDatabases = [ "wvwbot" ];
    ensureUsers = map (user: {
      name = user;
      ensureClauses.superuser = true;
      ensureDBOwnership = true;
    }) [ "wvwbot" ];
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [ "wvwbot" ];
  };

  users.users.wvwbot = {
    isSystemUser = true;
    group = "wvwbot";
    extraGroups = [ "postgres" ];
  };
  users.groups.wvwbot = { };

  systemd.services.wvwbot = {
    description = "wvwbot";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "redis-wvwbot.service"
      "postgresql.service"
    ];
    wants = [
      "network-online.target"
      "redis-wvwbot.service"
      "postgresql.service"
    ];
    serviceConfig = {
      User = "wvwbot";
      Restart = "always";
      EnvironmentFile = "/run/keys/wvwbot";
      # WorkingDirectory = "/etc/wvwbot";
      ExecStart = "${pkg}/bin/wvwbot";
      #RuntimeMaxSec = 86400;
    };
  };

  alerts = [
    "wvwbot"
    "redis-wvwbot"
  ];

  services.nginx.virtualHosts."wvwbot.greaka.de" = {
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:4040";
    useACMEHost = "greaka.de";
  };

  keys.wvwbot = {
    services = [ "wvwbot" ];
    user = "wvwbot";
  };
}
