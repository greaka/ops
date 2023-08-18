{ lib, pkgs, config, ... }:
let
  interfaceNames = lib.attrsets.mapAttrsToList (name: value: name)
    config.networking.wireguard.interfaces;
  serviceNames = builtins.map (name: "wireguard-${name}") interfaceNames;
  ports = lib.attrsets.mapAttrsToList (name: value: value.listenPort)
    config.networking.wireguard.interfaces;
in {
  systemd.services = lib.genAttrs serviceNames (name: {
    wants = [ "wg-key.service" ];
    after = [ "wg-key.service" ];
    before = lib.mkForce [ ];
  });

  networking.nat.enable = true;
  networking.nat.internalInterfaces = interfaceNames;
  networking.firewall.allowedUDPPorts = ports;

  networking.wireguard.interfaces = {
    wg0 = let ip_prefix = "10.100.0";
    in {
      ips = [ "${ip_prefix}.1/24" ];

      listenPort = 50820;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${ip_prefix}.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${ip_prefix}.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
      '';

      privateKeyFile = "/run/keys/wg";

      peers = [{ # Greaka Arch Desktop
        publicKey = "N9/WeSGj+EW1WpsXohO7rktVlTr/OhktBiybpIOScRk=";
        allowedIPs = [ "${ip_prefix}.2/32" ];
      }];
    };
  };

  alerts = serviceNames;

  keys.wg.services = serviceNames;
}
