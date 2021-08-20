{ lib, ... }:
let redirects = lib.mapAttrs' (host: target: lib.nameValuePair "${host}.greaka.de" {
  addSSL = true;
  useACMEHost = "greaka.de";
  locations."/".extraConfig = ''
    rewrite ^ ${target} permanent;
  '';
});
in
{
  services.nginx.virtualHosts = redirects {
    hetzner = "https://hetzner.cloud/?ref=s0gJP2Xf2FXH";
    sc = "https://robertsspaceindustries.com/enlist?referral=STAR-KZZK-V9HG";
  };
}
