{ ... }:
{
    imports = [
        ./redirects.nix
    ];

    users.users.nginx = {
        isSystemUser = true;
        extraGroups = ["acme"];
    };

    services.nginx = {
        enable = true;
#        user = "root";
#        group = "acme";
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    alerts = ["nginx"];
}
