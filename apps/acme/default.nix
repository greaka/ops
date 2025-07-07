{ config, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@greaka.de";
      dnsProvider = "cloudflare";
      credentialsFile = config.keys.acme-cloudflare.path;
    };
    certs."greaka.de".extraDomainNames = [ "*.greaka.de" ];
  };

  keys."acme-cloudflare" = {
    services = [ "acme-setup" ];
    group = "acme";
    permissions = "0440";
  };
}
