{
  network = {
    description = "greaka cloud";
    storage.legacy = {};
  };

  defaults = { imports = [ ./common.nix ]; };

  kenma = { ... }: {
    imports = [
      ./hetzner
      ./secrets.nix
      ./apps/utils/alerting
      ./apps/utils/restic

      ./apps/utils/nginx
      ./apps/services/wvwbot
      ./apps/misc/plikd
      ./apps/games/terraria
      ./apps/games/factorio
      ./apps/games/vintagestory
      ./apps/misc/ovenmediaengine
      # ./apps/misc/github-runner
      ./apps/misc/paperless
      ./apps/infra/wireguard
      ./apps/infra/matrix
      ./apps/infra/vaultwarden
    ];

    hetzner = {
      hostName = "kenma";
      ipv4 = "162.55.178.86";
      ipv6 = "2a01:4f8:1c1c:94e6::";
    };

    networking.hostId = "a7344d84";
  };
}

