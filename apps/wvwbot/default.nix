{ pkgs, ... }:
let secret = "wvwbot-config.json";
in
{
    imports = [
    ./override.nix
    ../redis
    ../acme
    ];

    users.users.wvwbot.isSystemUser = true;

    systemd.services.wvwbot = {
      description = "wvwbot";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target" "redis.service" "${secret}-key.service"];
      wants = ["redis.service" "${secret}-key.service"];
      serviceConfig = {
        User = "root";
        Restart = "always";
        WorkingDirectory = "/etc/wvwbot";
        ExecStart = "${pkgs.wvwbot}/bin/discordwvwbot";
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

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
