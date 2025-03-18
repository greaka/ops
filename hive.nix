{
  defaults =
    { name, ... }:
    {
      imports = [
        ./common.nix
        ./hetzner
        (./machines + "/${name}")
        ./secrets.nix
        ./apps/alerting
        ./apps/restic
      ];
    };

  kenma =
    { ... }:
    {
      imports = [
        ./apps/factorio
        # ./apps/terraria
        ./apps/vintagestory
        # ./apps/github-runner
        ./apps/ovenmediaengine
        # ./apps/paperless
        ./apps/atuin
        ./apps/plikd
        # ./apps/matrix
        ./apps/vaultwarden
        ./apps/wireguard
        # ./apps/wvwbot
        ./apps/nginx
      ];
    };

  # vintage =
  #   { ... }:
  #   {
  #     imports = [ ./apps/vintagestory ];
  #   };
}
