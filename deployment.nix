with builtins;
let
secrets = import ./secrets.nix;
in
{
    network.description = "greaka cloud";

    defaults = {
        imports = [ ./common.nix ];
    };

    kenma =
    { resources, ... }:
    {
        imports = [
        ./hetzner
        ./apps/wvwbot
        ./apps/terraria
        ];

        hetzner = {
            hostName = "kenma";
            ipv4 = "162.55.178.86";
            ipv6 = "2a01:4f8:1c1c:94e6::";
        };

        networking.hostId = "a7344d84";

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
    };
}

