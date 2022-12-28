{ lib, config, ... }: {
  systemd.services = lib.genAttrs config.alerts
    (name: { onFailure = [ "alert-telegram@%n.service" ]; });
  deployment.healthChecks.cmd = builtins.map (name: {
    description = "systemctl check ${name}";
    cmd = [ "systemctl" "is-active" "--quiet" name ];
    timeout = 60;
    period = 1;
  }) config.alerts;
}
