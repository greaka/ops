{ lib, pkgs, ... }:
let
  secret = "telegram-alerts-token";
  script = pkgs.writeScriptBin "notify-telegram" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.curl}/bin/curl -X POST --silent --output /dev/null https://api.telegram.org/bot$(cat /run/keys/${secret})/sendMessage -d chat_id=121591954 -d text="$2: $1"
  '';
in
{
  imports = [
    ./options.nix
    ./alerts.nix
  ];

  users.users."alert-telegram" = {
    isSystemUser = true;
    extraGroups = [ "keys" ];
  };

  systemd.services."alert-telegram@" = {
    description = "send a notification about failed systemd services";
    after = [ "network-online.target" "${secret}-key.service" ];
    wants = [ "${secret}-key.service" ];
    serviceConfig = {
      User = "alert-telegram";
      ExecStart = "${script}/bin/notify-telegram %I %H";
    };
  };
}
