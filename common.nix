{ config, pkgs, lib, ... }:
let
keys = lib.splitString "\n" (builtins.readFile (builtins.fetchurl "https://github.com/greaka.keys"));
in
{
  nixpkgs.config.allowUnfree = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  #system.autoUpgrade.enable = true;

  networking.firewall.logRefusedConnections = false;
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    ports = [32];
  };
  users.users.root.openssh.authorizedKeys.keys = keys;
}
