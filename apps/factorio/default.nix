{ lib, pkgs, ... }:
#let pkgs = import <nixos-master> { config.allowUnfree = true; };
let
  pinned = (let
    hostPkgs = import <nixpkgs> { };
    pinnedPkgs = hostPkgs.fetchFromGitHub {
      owner = "greaka";
      repo = "nixpkgs";
      rev = "402663dc19c3961bf52063bb720c58087b567675";
      sha256 = "sha256-V+SvPmX7HvZzMzCbKxZCgW0QC1+iwOkR6/upWTpLmto=";
    };
  in import pinnedPkgs { config.allowUnfree = true; });
in {
  services.factorio = {
    enable = true;
    admins = [ "Greaka" ];
    # package = pinned.factorio-headless;

    game-name = "Greaka Inc.";
    openFirewall = true;
    requireUserVerification = false;
    nonBlockingSaving = true;
    saveName = "knoedelsuppe";

    mods = import ./mods.nix { inherit lib pkgs; };
    mods-dat = /home/greaka/.factorio/mods/mod-settings.dat;
  };

  alerts = [ "factorio" ];
  backups = [ "/var/lib/factorio/saves" ];
}
