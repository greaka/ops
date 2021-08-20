{ ... }:
{
  security.acme = {
    email = "acme@greaka.de";
    acceptTerms = true;
    certs."greaka.de" = {
      dnsProvider = "cloudflare";
      extraDomainNames = [ "*.greaka.de" ];
      credentialsFile = "/run/keys/acme-cloudflare";
    };
  };
}
