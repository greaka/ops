{ ... }:
#let pkgs = import <nixos-master> { config.allowUnfree = true; };
#in
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
    };
}
