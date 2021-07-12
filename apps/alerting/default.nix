{ lib, ... }:
let secret = "telegram-alerts-token";
in
{
    imports = [
      ./options.nix
      ./alerts.nix
    ];

    users.users."alert-telegram" = {
        isSystemUser = true;
    };

    systemd.services."alert-telegram@" = {
      description = "sends a notification about failed systemd services";
      after = ["network-online.target" "${secret}-key.service"];
      wants = ["${secret}-key.service"];
      script = ''
        export BOT_TOKEN=$(cat /run/keys/${secret})
        curl -X POST --silent --output /dev/null https://api.telegram.org/bot$BOT_TOKEN/sendMessage -d chat_id=121591954 -d text="$(%H): $(%I)"
      '';
      serviceConfig = {
        User = "alert-telegram";
      };
    };
}
