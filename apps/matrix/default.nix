{ config, lib, ... }:
{
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      server_name = "greaka.de";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8448 ];
  services.nginx.virtualHosts."greaka.de" = {
    forceSSL = true;
    useACMEHost = "greaka.de";
    listen = with lib; flatten (map (addr: map (port: {inherit addr port; ssl = true;}) [443 8448]) config.services.nginx.defaultListenAddresses);
    locations."/_matrix" = {
      proxyPass = "http://localhost:${builtins.toString config.services.matrix-conduit.settings.global.port}";
      priority = 200;
    };
  };

  alerts = [ "conduit" ];
  backups = [ "/var/lib/matrix-conduit" ];
}