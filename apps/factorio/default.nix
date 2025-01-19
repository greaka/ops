{
  config,
  lib,
  pkgs,
  ...
}:
#let pkgs = import <nixos-master> { config.allowUnfree = true; };
let
  pinned = (
    let
      hostPkgs = import <nixpkgs> { };
      pinnedPkgs = hostPkgs.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "2d545bfee669dbe76898b5fece34c63cb5f68379";
        sha256 = "sha256-/B0wj5K9uObqQsN1C6aIxZINiR99D1p99sFz49z2iuE=";
      };
    in
    import pinnedPkgs { config.allowUnfree = true; }
  );
in
{
  services.factorio = {
    enable = true;
    admins = [ "Greaka" ];
    #package = pinned.factorio-headless;

    game-name = "Greaka Inc.";
    port = 34197;
    openFirewall = true;
    requireUserVerification = false;
    nonBlockingSaving = true;
    saveName = "spaceage";

    # mods = import ./mods.nix { inherit config lib pkgs; };
    # mods-dat = /home/greaka/.factorio/mods/mod-settings.dat;
  };

  alerts = [ "factorio" ];
  backups = [ "/var/lib/factorio/saves" ];
}
