{ config, lib, pkgs, ... }:
#let pkgs = import <nixos-master> { config.allowUnfree = true; };
let
  pinned = (
    let
      hostPkgs = import <nixpkgs> { };
      pinnedPkgs = hostPkgs.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "31ab653f7eba280bb188abf6473e3edf135a1d6f";
        sha256 = "sha256-30gyK0TvqVht8n1BDyLilk6hmGqkSLdEkezV3/Vkfi4=";
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
  backups = [ "/var/lib/factorio/saves/*" ];
}
