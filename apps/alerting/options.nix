{ lib, ... }:
with lib;
{
  options.alerts = mkOption {
    default = [ ];
    type = types.listOf types.str;
    description = ''
      A list of systemd service units to add telegram alerting to.
    '';
  };
}
