{ config, ... }:
builtins.listToAttrs (builtins.map (service: { systemd.services.${service}.onFailure = ["alert-telegram@%n"]; }) config.alerts)
