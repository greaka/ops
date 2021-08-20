{ pkgs, ... }:
let secret = "wvwbot-config.json";
in
{
  imports = [ ./override.nix ../redis ../acme ];

  users.users.wvwbot = {
    isSystemUser = true;
    extraGroups = [ "acme" ];
  };

  systemd.services.wvwbot = {
    description = "wvwbot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "redis.service" "${secret}-key.service" ];
    wants = [ "redis.service" "${secret}-key.service" ];
    serviceConfig = {
      User = "wvwbot";
      Restart = "always";
      WorkingDirectory = "/etc/wvwbot";
      ExecStart = "${pkgs.wvwbot}/bin/discordwvwbot";
      RuntimeMaxSec = 86400;
    };
  };

  alerts = [ "wvwbot" ];

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
}
