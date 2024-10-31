{ pkgs, lib, ... }:
let
  keys = lib.splitString "\n" (
    builtins.readFile (builtins.fetchurl "https://github.com/greaka.keys")
  );
in
{
  imports = [
    (
      let
        module = fetchTarball {
          name = "source";
          url = "https://git.lix.systems/lix-project/nixos-module/archive/2.90.0.tar.gz";
          sha256 = "sha256-yEO2cGNgzm9x/XxiDQI+WckSWnZX63R8aJLBRSXtYNE=";
        };
        lixSrc = fetchTarball {
          name = "source";
          url = "https://git.lix.systems/lix-project/lix/archive/2.90.0.tar.gz";
          sha256 = "sha256-f8k+BezKdJfmE+k7zgBJiohtS3VkkriycdXYsKOm3sc=";
        };
      in
      # This is the core of the code you need; it is an exercise to the
      # reader to write the sources in a nicer way, or by using npins or
      # similar pinning tools.
      import "${module}/module.nix" { lix = lixSrc; }
    )
  ];

  nixpkgs.config.allowUnfree = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  #system.autoUpgrade.enable = true;

  networking.firewall.logRefusedConnections = false;
  services.openssh = {
    enable = true;
    settings.passwordAuthentication = false;
    ports = [ 32 ];
  };
  users.users.root.openssh.authorizedKeys.keys = keys;

  # slim down the image
  system.disableInstallerTools = true;
  environment.defaultPackages = [ ];
  boot.enableContainers = lib.mkDefault false;
  boot.kernel.sysctl."fs.file-max" = 500000;
  documentation.enable = false;
  # nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
