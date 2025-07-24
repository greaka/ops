{
  pkgs,
  ...
}:
let
  pinned = (
    let
      pinnedPkgs = pkgs.fetchFromGitHub {
        owner = "greaka";
        repo = "nixpkgs";
        rev = "4544964802e749d1da42c92347906e2dea25524c";
        sha256 = "sha256-vO01kIzJt11Avh7mu28A/PQHyPa3dWITUrztyIQgwDk=";
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
