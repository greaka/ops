{ config, lib, ... }:
with builtins;
let readSecret = name: readFile (./secrets + "/${name}");
    secrets = mapAttrs (name: type: if type != "directory" then readSecret name else null) (readDir ./secrets);
in
{
  options.keys = with lib; mkOption {
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
  config.deployment.keys = mapAttrs (name: value: value // {
    text = secrets."${name}";
  }) config.keys;
}
