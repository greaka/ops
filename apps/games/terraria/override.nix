{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.terraria;
  worldSizeMap = {
    small = 1;
    medium = 2;
    large = 3;
  };
  valFlag = name: val:
    optionalString (val != null)
      ''-${name} "${escape [ "\\" ''"'' ] (toString val)}"'';
  boolFlag = name: val: optionalString val "-${name}";
  flags = [
    (valFlag "port" cfg.port)
    (valFlag "maxPlayers" cfg.maxPlayers)
    (valFlag "password" cfg.password)
    (valFlag "motd" cfg.messageOfTheDay)
    (valFlag "world" cfg.worldPath)
    (valFlag "autocreate"
      (builtins.getAttr cfg.autoCreatedWorldSize worldSizeMap))
    (valFlag "banlist" cfg.banListPath)
    (boolFlag "secure" cfg.secure)
    (boolFlag "noupnp" cfg.noUPnP)
  ];
in
{
  config = {
    nixpkgs.config.packageOverrides = pkgs: {
      terraria-server = pkgs.callPackage ./package.nix {};
    };

    systemd.services.terraria.serviceConfig.User = mkForce "root";
    users.users.terraria.group = "terraria";
    users.groups.terraria = {};

    # users.users.terraria.extraGroups = ["tty"];

    # systemd.services.terraria = {
    #   postStart = "";
    #   serviceConfig = mkForce {
    #     User = "root";
    #     Type = "simple";
    #     ExecStart = "${pkgs.terraria-server}/bin/TerrariaServer ${concatStringsSep " " flags}";
    #     #Restart = "always";
    #     # needed because tshock crashes when no stdin
    #     StandardInput = "tty";
    #     # Hijack tty11 for this purpose
    #     TTYPath = "/dev/tty11";
    #     # all output should stay in the journal though
    #     StandardOutput = "journal";
    #   };
    # };

    # systemd.services.terraria = {
    #   postStart = "";
    #   serviceConfig = mkForce {
    #     User = "terraria";
    #     Type = "forking";
    #     GuessMainPID = true;
    #     ExecStart = "${getBin pkgs.screen}/bin/screen -DmUS terraria ${pkgs.terraria-server}/bin/TerrariaServer ${concatStringsSep " " flags}";
    #     ExecStop = "${getBin pkgs.screen}/bin/screen -S terraria -X stuff \"exit^M\"";
    #     TTYPath = "/dev/tty11";
    #   };
    # };
  };
}
