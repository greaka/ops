with builtins;
let
secrets = import ./secrets.nix;
in
{
    network.description = "greaka cloud";

    defaults = {
        imports = [ ./common.nix ];
    };

    cpx21n1 =
    { resources, ... }:
    {
        imports = [
        ./hetzner.nix
        ];

        hetzner = {
            hostName = "kenma";
            ipv4 = "162.55.178.86";
            ipv6 = "2a01:4f8:1c1c:94e6::";
        };

        networking.hostId = "a7344d84";
    };
}

