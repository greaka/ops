{ ... }:
{
  imports = [
    ./boot.nix
    ./pod.nix
  ];

  service.k3s.enable = true;
}
