{ pkgs, ... }:
{
  imports = [ ./override.nix ];

  users.users.ovenmediaengine = {
    isSystemUser = true;
    group = "ovenmediaengine";
  };
  users.groups.ovenmediaengine = {};

  systemd.services.ovenmediaengine = {
    description = pkgs.ovenmediaengine.meta.description;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "forking";
      PIDFile = "/run/ovenmediaengine.pid";
      # User = "ovenmediaengine";
      Restart = "always";
      RestartSec = "2";
      RestartPreventExitStatus = "1";
      ExecStart = "${pkgs.ovenmediaengine}/bin/OvenMediaEngine -d -c ${./config}";
      StandardOutput = "null";
      LimitNOFILE = "65536";
    };
  };

  alerts = [ "ovenmediaengine" ];

  services.nginx.virtualHosts."stream.greaka.de" = {
    forceSSL = true;
    locations."/" = {
      root = ./html;
      index = "index.html";
    };
    locations."/ws" = {
      priority = 999;
      proxyWebsockets = true;
      proxyPass = "http://localhost:3333/app/stream";
    };
    useACMEHost = "greaka.de";
  };

  networking.firewall.allowedTCPPorts = [ 1935 3478 ];
}
