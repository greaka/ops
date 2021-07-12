{ lib, config, ... }: {
  systemd.services = lib.genAttrs config.alerts (name: {
    onFailure = [ "alert-telegram@%n" ];
  });
}
