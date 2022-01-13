{ pkgs, ... }:
#let pkgs = import <nixos-master> { config.allowUnfree = true; };
let modpack = pkgs.callPackage ./mods.nix {};
in
{
    services.factorio = {
        enable = true;
        admins = [
            "Greaka"
        ];
        # package = pkgs.factorio-headless;

        game-name = "Greaka Inc.";
        openFirewall = true;
        requireUserVerification = false;
        nonBlockingSaving = true;
        saveName = "jappies";

        mods = [modpack];
    };

    backups = [ "/var/lib/factorio/saves" ];
}
