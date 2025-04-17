{ ... }:
{
  fileSystems = {
    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/sda15";
      fsType = "vfat";
    };
  };

  hetzner = {
    interface = "eth0";
    ipv4 = "116.203.149.217";
    ipv6 = "2a01:4f8:c2c:dbc6::1";
  };

  networking.hostId = "bea9e48b";
  system.stateVersion = "25.05";
}
