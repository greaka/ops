let
  defaults = [
    ./common.nix
    ./hetzner
    ./secrets.nix
    ./apps/utils/alerting
    ./apps/utils/restic
  ];
in {
  kenma = { ... }: {
    imports = defaults ++ [
      ./apps/games/factorio
      ./apps/games/terraria
      ./apps/games/vintagestory
      # ./apps/misc/github-runner
      ./apps/misc/ovenmediaengine
      ./apps/misc/paperless
      ./apps/misc/plikd
      ./apps/infra/matrix
      ./apps/infra/vaultwarden
      ./apps/infra/wireguard
      ./apps/services/wvwbot
      ./apps/utils/nginx
    ];

    hetzner = {
      hostName = "kenma";
      ipv4 = "162.55.178.86";
      ipv6 = "2a01:4f8:1c1c:94e6::";
    };

    networking.hostId = "a7344d84";
    system.stateVersion = "23.05";
  };
}

