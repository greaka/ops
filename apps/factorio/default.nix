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
        rev = "1a73b1445c0fe7b5af7bac591a94d0d7115c70f2";
        sha256 = "sha256-Zo2FQiOqN0e3M/OExsam0mwRAbDtWoDasjFv1JvaF/8=";
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
    saveName = "speeed";

    # mods = import ./mods.nix { inherit config lib pkgs; };
    # mods-dat = /home/greaka/.factorio/mods/mod-settings.dat;
  };

  alerts = [ "factorio" ];
  backups = [ "/var/lib/factorio/saves" ];
}
