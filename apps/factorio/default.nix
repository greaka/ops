{ lib, pkgs, ... }:
#let pkgs = import <nixos-master> { config.allowUnfree = true; };
let
  pinned = (
    let
      hostPkgs = import <nixpkgs> { };
      pinnedPkgs = hostPkgs.fetchFromGitHub {
        owner = "greaka";
        repo = "nixpkgs";
        rev = "8837856719e27fcf0aec16c5331ad69ccbf8aef2";
        sha256 = "sha256-o3V+5XnF6vBAHB3GsvOpiIp5/bD3bbIdx5qMK1NbI6g=";
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
    openFirewall = true;
    requireUserVerification = false;
    nonBlockingSaving = true;
    saveName = "knoedelsuppe";

    mods = import ./mods.nix { inherit lib pkgs; };
    mods-dat = /home/greaka/.factorio/mods/mod-settings.dat;
  };

  alerts = [ "factorio" ];
  backups = [ "/var/lib/factorio/saves/*" ];
}
