{ ... }: {
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@greaka.de";
      dnsProvider = "cloudflare";
      credentialsFile = "/run/keys/acme-cloudflare";
    };
    certs."greaka.de".extraDomainNames = [ "*.greaka.de" ];
  };

  keys."acme-cloudflare" = {
    group = "acme";
    permissions = "0440";
  };
}
