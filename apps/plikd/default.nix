{ config, ... }:
{
  imports = [
    ../acme
  ];

  users.users.plikd = {
    isSystemUser = true;
    extraGroups = [ "acme" ];
  };

  services.plikd = {
    enable = true;
    openFirewall = true;
    settings = {
      ListenAddress = "0.0.0.0";
      ListenPort = 8080;
      SslEnabled = true;
      SslCert = "/var/lib/acme/greaka.de/fullchain.pem";
      SslKey = "/var/lib/acme/greaka.de/key.pem";
      DownloadDomain = "https://dl.greaka.de";
      EnhancedWebSecurity = false;
      Authentication = true;
      NoAnonymousUploads = true;
      maxTTL = 315576000;
    };
  };

  services.nginx.virtualHosts."dl.greaka.de" = {
    forceSSL = true;
    locations."/".proxyPass = "https://localhost:${toString config.services.plikd.settings.ListenPort}";
    useACMEHost = "greaka.de";
  };

  services.nginx.clientMaxBodySize = "1G";

  alerts = [ "plikd" ];
}
