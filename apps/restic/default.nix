{ config, lib, ... }:
{
  imports = [ ./options.nix ];

  services.restic.backups.backblaze = {
    repository = "b2:greaka-kenma:/backups/backblaze";
    paths = config.backups;
    initialize = true;
    passwordFile = "/run/keys/restic";
    environmentFile = "/run/keys/backblaze";
    pruneOpts = [
      "--keep-daily 10"
      "--max-unused 0"
    ];
  };

  systemd.services."restic-backups-backblaze".serviceConfig.PrivateTmp = lib.mkForce false;

  keys.backblaze = { };
  keys.restic = { };
}
