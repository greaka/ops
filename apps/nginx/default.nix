{ ... }: {
  imports = [ ./redirects.nix ./static.nix ];

  users.users.nginx = {
    isSystemUser = true;
    extraGroups = [ "acme" ];
  };

  services.nginx = {
    enable = true;
    enableReload = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  alerts = [ "nginx" ];
}
