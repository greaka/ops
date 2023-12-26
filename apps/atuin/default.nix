{ config, ... }: {
  services.atuin = {
    enable = true;
    port = 9712;
    openRegistration = false;
    database.uri = "postgresql:///atuin?host=/run/postgresql&port=${toString config.services.postgresql.port}";
  };

  services.nginx.virtualHosts."atuin.greaka.de" = {
    forceSSL = true;
    locations."/".proxyPass =
      "http://127.0.0.1:${toString config.services.atuin.port}";
    useACMEHost = "greaka.de";
  };
}
