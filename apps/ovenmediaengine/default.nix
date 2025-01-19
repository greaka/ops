args@{
  lib,
  pkgs,
  config,
  ...
}:
let
  streamKey = host: builtins.readFile (./keys + "/${host}");
  hosts = lib.reverseList (
    builtins.filter (x: !(lib.hasPrefix "." x)) (builtins.attrNames (builtins.readDir ./keys))
  );
  genHosts =
    fn:
    lib.attrsets.mapAttrs' (name: value: lib.attrsets.nameValuePair (name + ".greaka.de") value) (
      lib.genAttrs hosts fn
    );
  logDir = "/var/log/ovenmediaengine";
  omeCfg = pkgs.callPackage ./config { inherit hosts logDir; };
  pkg =
    with pkgs;
    ((oven-media-engine.overrideAttrs { patches = [ ]; }).override { ffmpeg = ffmpeg_6; });
in
{
  imports = [ (import ./all.nix (args // { inherit hosts; })) ];

  users.users.ovenmediaengine = {
    isSystemUser = true;
    group = "ovenmediaengine";
    extraGroups = [ "acme" ];
  };
  users.groups.ovenmediaengine = { };

  systemd.services.ovenmediaengine = {
    description = pkg.meta.description;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      OME_ICE_CANDIDATES = "${config.hetzner.ipv4}:10016/udp";
      CERT_FULL_CHAIN = "/var/lib/acme/greaka.de/fullchain.pem";
      CERT_KEY = "/var/lib/acme/greaka.de/key.pem";
    };
    serviceConfig = {
      Type = "forking";
      PIDFile = "/run/ovenmediaengine.pid";
      # User = "ovenmediaengine";
      Restart = "always";
      RestartSec = "2";
      RestartPreventExitStatus = "1";
      ExecStart = "${pkg}/bin/OvenMediaEngine -d -c ${omeCfg}";
      StandardOutput = "null";
      LimitNOFILE = "65536";
    };
  };

  alerts = [ "ovenmediaengine" ];

  systemd.services.ovenmediaengine-cleanup = {
    description = "Clean log directory of ovenmediaengine";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c \"find ${logDir}/* -mtime +7 -exec rm {} \\;\"";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.timers.ovenmediaengine-cleanup = {
    description = "Timer for ovenmediaengine cleanup";
    timerConfig = {
      OnCalendar = lib.mkDefault "23:00";
      Persistent = "true";
      Unit = "ovenmediaengine-cleanup.service";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.nginx.virtualHosts = genHosts (host: {
    forceSSL = true;
    locations."/" = {
      root = ./html;
      index = "index.html";
    };
    locations."/ws" = {
      priority = 950;
      proxyWebsockets = true;
      proxyPass = "http://localhost:3333/app/${streamKey host}?direction=recv";
    };
    locations."/app" = {
      priority = 930;
      proxyPass = "https://stream.greaka.de:8082";
    };
    locations."/llhls" = {
      priority = 955;
      proxyPass = "https://stream.greaka.de:8082/app/${streamKey host}/llhls.m3u8";
    };
    locations."/ingest" = {
      priority = 960;
      proxyWebsockets = true;
      proxyPass = "http://localhost:3333/app/";
    };
    locations."= /viewers" = {
      priority = 980;
      proxyPass = "http://localhost:8081/v1/stats/current/vhosts/default/apps/app/streams/${streamKey host}";
      extraConfig = ''
        add_header Access-Control-Allow-Origin * always;
        proxy_set_header Accept-Encoding "";
        proxy_set_header authorization "Basic Zm9v";
        sub_filter '${streamKey host}' '${host}';
        sub_filter_types application/json;
        proxy_intercept_errors off;
        error_page 404 = /viewers/error;
      '';
    };
    useACMEHost = "greaka.de";
  });

  networking.firewall.allowedTCPPorts = [
    1935
    3478
    3334
  ];
  networking.firewall.allowedUDPPorts = [
    10016
    9999
  ];
}
