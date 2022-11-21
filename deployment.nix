with builtins;
let secrets = import ./secrets.nix;
in
{
  network = {
    description = "greaka cloud";
    storage.legacy = {};
  };

  defaults = { imports = [ ./common.nix ]; };

  kenma = { ... }: {
    imports = [
      ./hetzner
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

    deployment.keys."backblaze" = {
      text = secrets."backblaze";
      permissions = "0400";
    };

    # deployment.keys."github-runner" = {
    #   text = secrets."github-runner";
    #   permissions = "0444";
    # };

    deployment.keys."paperless" = {
      text = secrets."paperless";
      permissions = "0400";
    };

    deployment.keys."restic" = {
      text = secrets."restic";
      permissions = "0400";
    };

    deployment.keys."wvwbot-config.json" = {
      text = secrets."wvwbot-config.json";
      user = "wvwbot";
      permissions = "0400";
    };

    deployment.keys."acme-cloudflare" = {
      text = secrets."acme-cloudflare";
      group = "acme";
      permissions = "0440";
    };

    deployment.keys."telegram-alerts-token" = {
      text = secrets."telegram-alerts-token";
      user = "alert-telegram";
      permissions = "0400";
    };

    deployment.keys."wg" = {
      text = secrets."wg";
      permissions = "0400";
    };

    deployment.keys."vaultwarden" = {
      text = secrets."vaultwarden";
      user = "vaultwarden";
      permissions = "0400";
    };
  };
}

