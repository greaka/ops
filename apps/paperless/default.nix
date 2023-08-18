{ config, ... }: {
  services.paperless = {
    enable = true;
    passwordFile = "/run/keys/paperless";
    extraConfig = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_MODE = "skip_noarchive";
    };
  };

  services.nginx.virtualHosts."paperless.greaka.de" = {
    forceSSL = true;
    locations."/".proxyPass =
      "http://localhost:${builtins.toString config.services.paperless.port}";
    useACMEHost = "greaka.de";
  };

  keys.paperless.services = [ "paperless-copy-password" ];
}
