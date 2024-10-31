{ config, lib, pkgs, ... }:
#let pkgs = import <nixos-master> { config.allowUnfree = true; };
let
  pinned = (
    let
      hostPkgs = import <nixpkgs> { };
      pinnedPkgs = hostPkgs.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "7e35ac30ea1d236419653182559367ecd8a30675";
        sha256 = "sha256-vG9m5BJm9cFYBr23bnaloZXLz4hkAsA/frPNr5YWt74=";
      };
    in
    import pinnedPkgs { config.allowUnfree = true; }
  );
in
{
  services.factorio = {
    enable = true;
    admins = [ "Greaka" ];
    package = pinned.factorio-headless;

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
