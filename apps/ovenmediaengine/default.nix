{ lib, pkgs, ... }:
let streamKey = host: builtins.readFile (./keys + "/${builtins.head (lib.splitString "." host)}");
    hosts = map (host: "${host}.greaka.de") ["stream" "janovi"];
in
{
  # imports = [ ./override.nix ];

  users.users.ovenmediaengine = {
    isSystemUser = true;
    group = "ovenmediaengine";
  };
  users.groups.ovenmediaengine = {};

  systemd.services.ovenmediaengine = {
    description = pkgs.oven-media-engine.meta.description;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "forking";
      PIDFile = "/run/ovenmediaengine.pid";
      # User = "ovenmediaengine";
      Restart = "always";
      RestartSec = "2";
      RestartPreventExitStatus = "1";
      ExecStart = "${pkgs.oven-media-engine}/bin/OvenMediaEngine -d -c ${./config}";
      StandardOutput = "null";
      LimitNOFILE = "65536";
    };
  };

  alerts = [ "ovenmediaengine" ];

  services.nginx.virtualHosts = lib.genAttrs hosts (host: {
    forceSSL = true;
    locations."/" = {
      root = ./html;
      index = "index.html";
    };
    locations."/ws" = {
      priority = 999;
      proxyWebsockets = true;
      proxyPass = "http://localhost:3333/app/${streamKey host}";
    };
    useACMEHost = "greaka.de";
  });

  # nginx can't allow dns
  # services.nginx.streamConfig  = ''
  #   server {
  #     listen 0.0.0.0:1934;
  #     allow home.greaka.de;
  #     proxy_pass localhost:1935;
  #   }
  # '';

  networking.firewall.allowedTCPPorts = [ 1935 9999 3478 ];
}
