{ config, lib, pkgs, ... }:
with builtins;
let
  keyStart = name:
    (pkgs.writeScriptBin "${name}-key-start" ''
      #!${pkgs.bash}/bin/bash
      set -e
      ${pkgs.inotify-tools}/bin/inotifywait -qq -e delete_self "/run/keys/${name}" &

      if [[ ! -e "/run/keys/${name}" ]]; then
        echo 'flapped up'
        exit 0
      fi
      wait %1
    '') + "/bin/${name}-key-start";
  keyStartPre = name:
    (pkgs.writeScriptBin "${name}-key-start-pre" ''
      #!${pkgs.bash}/bin/bash
      set -e
      (while read f; do if [ "$f" = "${name}" ]; then break; fi; done \
        < <(${pkgs.inotify-tools}/bin/inotifywait -qm --format '%f' -e create,move /run/keys) ) &

      if [[ -e "/run/keys/${name}" ]]; then
        echo 'flapped down'
        kill %1
        exit 0
      fi
      wait %1
    '') + "/bin/${name}-key-start-pre";
in {
  options.keys = with lib;
    mkOption {
      type = types.attrsOf (types.submodule ({
        options = {
          user = mkOption {
            type = types.str;
            default = "root";
          };
          group = mkOption {
            type = types.str;
            default = "root";
          };
          permissions = mkOption {
            type = types.str;
            default = "0400";
          };
        };
      }));
    };
  config.deployment.secrets = mapAttrs (name: value: {
    source = "./secrets/${name}";
    destination = "/run/keys/${name}";
    owner = {
      user = value.user;
      group = value.group;
    };
    permissions = value.permissions;
    action = [ "systemctl" "start" "${name}-key.service" ];
  }) config.keys;
  config.systemd.services = lib.attrsets.mapAttrs' (name: value:
    lib.attrsets.nameValuePair (name + "-key") {
      serviceConfig = {
        ExecStart = keyStart name;
        ExecStartPre = keyStartPre name;
        Restart = "always";
        RestartSec = "100ms";
        TimeoutStartSec = "infinity";
      };
    }) config.keys;
}
