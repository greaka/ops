# things that are specific to the machine we're running on,
# kind of like /etc/nixos/hardware-configuration.conf, but
# with extra steps
{
  config,
  lib,
  name,
  ...
}:
let
  ipv4 = config.hetzner.ipv4 != null;
  ipv6 = config.hetzner.ipv6 != null;
  gateway4 = lib.optionalString ipv4 "172.31.1.1";
  gateway6 = lib.optionalString ipv6 "fe80::1";
in
{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ./options.nix
  ];

  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
      };
    };
  };

  swapDevices = [
    {
      device = "/swap";
      size = 8192;
    }
  ];

  networking = {
    hostName = name;
    nameservers =
      (lib.optionals ipv4 [
        "185.12.64.1"
        "185.12.64.2"
      ])
      ++ (lib.optionals ipv6 [
        "2a01:4ff:ff00::add:1"
        "2a01:4ff:ff00::add:2"
      ]);

    useDHCP = false;

    defaultGateway = {
      address = gateway4;
      interface = config.hetzner.interface;
    };

    defaultGateway6 = {
      address = gateway6;
      interface = config.hetzner.interface;
    };

    interfaces."${config.hetzner.interface}" = {
      useDHCP = false;

      ipv4 = {
        addresses = lib.optionals ipv4 [
          {
            address = config.hetzner.ipv4;
            prefixLength = 32;
          }
        ];
      };

      ipv6 = {
        addresses = lib.optionals ipv6 [
          {
            address = config.hetzner.ipv6;
            prefixLength = 64;
          }
        ];
      };
    };

    nat.externalInterface = config.hetzner.interface;
  };

  deployment.targetHost = name;
}
