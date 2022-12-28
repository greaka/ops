{ pkgs, ... }:
let secret = "wvwbot-config.json";
in {
  imports = [ ./override.nix ];

  services.redis.servers.wvwbot = {
    enable = true;
    port = 6379;
  };
  backups = [ "/var/lib/redis-wvwbot/dump.rdb" ];

  users.users.wvwbot = {
    isSystemUser = true;
    group = "wvwbot";
  };
  users.groups.wvwbot = { };

  systemd.services.wvwbot = {
    description = "wvwbot";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "redis-wvwbot.service"
      "${secret}-key.service"
    ];
    wants = [ "redis-wvwbot.service" "${secret}-key.service" ];
    serviceConfig = {
      User = "wvwbot";
      Restart = "always";
      WorkingDirectory = "/etc/wvwbot";
      ExecStart = "${pkgs.wvwbot}/bin/discordwvwbot";
      #RuntimeMaxSec = 86400;
    };
  };

  alerts = [ "wvwbot" "redis-wvwbot" ];

  services.nginx.virtualHosts."wvwbot.greaka.de" = {
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:4040";
    useACMEHost = "greaka.de";
    default = true;
  };

  environment.etc.wvwbot = {
    source = "/run/keys/${secret}";
    target = "wvwbot/config.json";
    user = "wvwbot";
    mode = "0400";
  };

  environment.etc.wvwbot-templates = {
    source = "${pkgs.wvwbot}/templates";
    target = "wvwbot/templates";
  };

  keys."wvwbot-config.json".user = "wvwbot";
}
