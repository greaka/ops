{ config, ... }:
{
  imports = [
    ../acme
    #./override.nix
  ];

  users.users.plikd = {
    isSystemUser = true;
    group = "plikd";
    extraGroups = [ "acme" ];
  };
  users.groups.plikd = { };

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
      AbuseContact = "plikd@greaka.de";
      EnhancedWebSecurity = false;
      FeatureAuthentication = "forced";
      FeatureExtendTTL = "default";
      maxTTLStr = "3650d";
    };
  };

  services.nginx.virtualHosts."dl.greaka.de" = {
    forceSSL = true;
    locations."/".proxyPass = "https://localhost:${toString config.services.plikd.settings.ListenPort}";
    useACMEHost = "greaka.de";
  };

  services.nginx.clientMaxBodySize = "10G";

  alerts = [ "plikd" ];
  backups = [ "/var/lib/plikd" ];
}
