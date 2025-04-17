{ ... }:
{
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

  hetzner = {
    interface = "enp1s0";
    ipv4 = "162.55.178.86";
    # hetzner needs the 1 at the end
    ipv6 = "2a01:4f8:1c1c:94e6::1";
  };

  networking.hostId = "a7344d84";
  system.stateVersion = "23.11";
}
