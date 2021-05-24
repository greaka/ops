{ config, pkgs, lib, ... }:
let
keys = [
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAU0d0aSgY9QFJfh6+Dy71ewidYaaU6O2FMlzaJTZZtXZNMLcQULpMlKny5gDGhoTm0LAOHWAfHTEmnTiXWnTyowkR/ttEno4dnKVjDMeLB//XDqvhIoZseqTAKsvjXoxFEAKQEY6q1grM75hK2df3CkTqMIoSeO5c8ICsEcknbRHr7ysCEGg99y1+QN2YZyi3THzcTv/jW0HB1p4o8JGEMTpPqJD1WmP/vxh9LPWB7h0LdRwGi4skHyvaT2a5wnKL8+Rw8SEcYWFAW3U7DsfVnzGsXvpo95JY/W2L1cMzSEPKWAO+/JLP8gncUegrRTop3DS+obvthj8gznV6TqVf/RXEqF1VLaRjDMD2JmDrhFcLtPbfLe8r5qY+xdjS9v8pbJnPNtDYLIg9GpvJv/JUbBckoj4Skoqw0f1Rf6/7NK9nbwgjV8F6Ro0rhPHStrrEj469s77IZkQIQByg2JPK0j/lO2Cxyaf4LuRSPljqwpuDUGG4MuzkNSd0cwzV/JIcBs945JCtZC+ILxkLdZIyBbZtILB1qOWDjCUeRUI11oz4npBfPOyfB6E/vek0FYnf5q5BjkE8+r2sjqPps16S5Z7B1Kxipsj31oi3/HprrPcBQU6CQvsiGaZxmUmSP8EvYZpowLyqJuJg2ErOBDxWe+7d4N5N7SXqneHWCMaKzQ=="
];
in
{
  nixpkgs.config.allowUnfree = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = keys;
}

