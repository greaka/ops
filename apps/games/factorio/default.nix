{ lib, pkgs, ... }:
#let pkgs = import <nixos-master> { config.allowUnfree = true; };
let
  pinned = (let
    hostPkgs = import <nixpkgs> { };
    pinnedPkgs = hostPkgs.fetchFromGitHub {
      owner = "greaka";
      repo = "nixpkgs";
      rev = "64d5deb13737790b50c0c0ae1042a1ac4e9922c4";
      sha256 = "0idpl6xiwn388bwh0jqllq3xmay1bkwqs1ymxzmxd267d5f8r8iy";
    };
  in import pinnedPkgs { config.allowUnfree = true; });
in {
  services.factorio = {
    enable = true;
    admins = [ "Greaka" ];
    #package = pinned.factorio-headless;

    game-name = "Greaka Inc.";
    openFirewall = true;
    requireUserVerification = false;
    nonBlockingSaving = true;
    saveName = "jappies";

    mods = import ./mods.nix {
      lib = lib;
      pkgs = pkgs;
    };
  };

  alerts = [ "factorio" ];
  backups = [ "/var/lib/factorio/saves" ];
}
