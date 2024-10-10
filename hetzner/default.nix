# things that are specific to the machine we're running on,
# kind of like /etc/nixos/hardware-configuration.conf, but
# with extra steps
{
  config,
  lib,
  name,
  ...
}:
{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ./options.nix
  ];

  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/sda2";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/sda1";
      fsType = "ext2";
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
    nameservers = [
      "213.133.98.98"
      "213.133.99.99"
      "213.133.100.100"
    ];

    useDHCP = false;

    defaultGateway = {
      address = "172.31.1.1";
      interface = "enp1s0";
    };

    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };

    interfaces.enp1s0 = {
      useDHCP = false;

      ipv4.addresses = [
        {
          address = config.hetzner.ipv4;
          prefixLength = 32;
        }
      ];

      ipv6.addresses = [
        {
          address = config.hetzner.ipv6;
          prefixLength = 64;
        }
      ];
    };

    nat.externalInterface = "enp1s0";
  };

  deployment.targetHost = name;
}
