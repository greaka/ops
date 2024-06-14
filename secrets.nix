{ config, lib, ... }:
with builtins;
with lib; {
  options.keys = mkOption {
    type = types.attrsOf (types.submodule ({
      options = {
        services = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
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
  config = {
    deployment.keys = mapAttrs (name: value: {
      keyFile = ./secrets + "/${name}";
      user = value.user;
      group = value.group;
      permissions = value.permissions;
    }) config.keys;

    systemd.services = let
      servicesOfSecret = name: value:
        listToAttrs (map (service: nameValuePair service name) value.services);
      keys = mapAttrs servicesOfSecret config.keys;
      filteredKeys = filterAttrs (name: value: value != { }) keys;
      serviceKeyPairs = mapAttrsToList (name: value: value) filteredKeys;
      services = foldl' (a: b: a // b) { } (flatten serviceKeyPairs);
    in mapAttrs (service: secret: {
      after = [ "${secret}-key.service" ];
      requires = [ "${secret}-key.service" ];
    }) services;
  };
}
