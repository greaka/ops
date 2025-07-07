{
  name,
  config,
  lib,
  ...
}:
let serviceName = "restic-backups-${name}";
    repo = builtins.readFile ../../secrets/restic_rep;
    userDomain = builtins.elemAt (lib.splitString ":" repo) 1;
    domain = builtins.elemAt (lib.splitString "@" userDomain) 1;
    known_hosts = builtins.readFile /home/greaka/.ssh/known_hosts;
    keyLine = builtins.head (builtins.filter (s: lib.hasPrefix "${domain} ssh-ed25519" s) (lib.splitString "\n" known_hosts));
    pubkey = lib.removePrefix "${domain} " keyLine;
in
{
  imports = [ ./options.nix ];

  services.restic.backups."${name}" = {
    repositoryFile = config.keys.restic_rep.path;
    paths = config.backups;
    initialize = true;
    passwordFile = config.keys.restic.path;
    extraOptions = [
      "sftp.args='-i ${config.keys.rsync_key.path}'"
    ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-hourly 24"
      "--keep-daily 7"
      "--keep-weekly 4"
    ];
  };

  systemd.services."${serviceName}".serviceConfig.PrivateTmp = lib.mkForce false;

  services.openssh.knownHosts = {
    "restic/ed25519" = {
      publicKey = pubkey;
      hostNames = [ domain ];
    };
  };

  keys.restic.services = [serviceName];
  keys.restic_rep.services = [serviceName];
  keys.rsync_key.services = [serviceName];
}
