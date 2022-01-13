{ lib, ... }:
with lib; {
  options.backups = mkOption {
    default = [ ];
    type = types.listOf types.str;
    description = ''
      A list of paths to backup.
    '';
  };
}
