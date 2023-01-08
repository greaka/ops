{ lib, pkgs, ... }:
let
  streamKey = host: builtins.readFile (./keys + "/${host}");
  hosts = [ "stream" "janovi" "leon" "pistolenjoe" ];
  genHosts = fn:
    lib.attrsets.mapAttrs'
    (name: value: lib.attrsets.nameValuePair (name + ".greaka.de") value)
    (lib.genAttrs hosts fn);
in {
  # imports = [ ./override.nix ];

  users.users.ovenmediaengine = {
    isSystemUser = true;
    group = "ovenmediaengine";
  };
  users.groups.ovenmediaengine = { };

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
      ExecStart =
        "${pkgs.oven-media-engine}/bin/OvenMediaEngine -d -c ${./config}";
      StandardOutput = "null";
      LimitNOFILE = "65536";
    };
  };

  alerts = [ "ovenmediaengine" ];

  services.nginx.virtualHosts = genHosts (host: {
    forceSSL = true;
    locations."/" = {
      root = ./html;
      index = "index.html";
    };
    locations."/ws" = {
      priority = 950;
      proxyWebsockets = true;
      proxyPass = "http://localhost:3333/app/${streamKey host}";
    };
    locations."= /viewers" = {
      priority = 980;
      proxyPass =
        "http://localhost:8081/v1/stats/current/vhosts/default/apps/app/streams/${
          streamKey host
        }";
      extraConfig = ''
        proxy_set_header authorization "Basic Zm9v";
        sub_filter '${streamKey host}' '${host}';
        proxy_intercept_errors on;
        error_page 404 = /viewers/error;
      '';
    };
    useACMEHost = "greaka.de";
  });

  networking.firewall.allowedTCPPorts = [ 1935 9999 3478 ];
}
