{ config, lib, pkgs, ... }:
with builtins; {
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
  config.deployment.keys = mapAttrs (name: value: {
    keyFile = ./secrets + "/${name}";
    user = value.user;
    group = value.group;
    permissions = value.permissions;
  }) config.keys;
}
