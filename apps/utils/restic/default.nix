{ config, ... }: {
  imports = [ ./options.nix ];

  services.restic.backups.backblaze = {
    repository = "b2:greaka-kenma:/backups/backblaze";
    paths = config.backups;
    initialize = true;
    passwordFile = "/run/keys/restic";
    environmentFile = "/run/keys/backblaze";
    pruneOpts = [ "--keep-daily 10" "--max-unused 0" ];
  };

  keys.backblaze = { };
  keys.restic = { };
}
