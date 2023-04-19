{
  defaults = { ... }: {
    imports =
      [ ./common.nix ./hetzner ./secrets.nix ./apps/alerting ./apps/restic ];
  };

  kenma = { ... }: {
    imports = [
      ./apps/factorio
      # ./apps/terraria
      # ./apps/vintagestory
      # ./apps/github-runner
      ./apps/ovenmediaengine
      ./apps/paperless
      ./apps/plikd
      ./apps/matrix
      ./apps/vaultwarden
      ./apps/wireguard
      ./apps/wvwbot
      ./apps/nginx
    ];

    hetzner = {
      ipv4 = "162.55.178.86";
      ipv6 = "2a01:4f8:1c1c:94e6::";
    };

    networking.hostId = "a7344d84";
    system.stateVersion = "23.05";
  };
}
