{ lib, pkgs, ... }:
with lib;
with builtins;
let
  srcUser = "greaka";
  source = /home + "/${srcUser}" + /.factorio/mods;
  modJson = importJSON "${source}/mod-list.json";
  activeMods = filter (x: x.enabled) modJson.mods;
  modNames = filter (x: x != "base") (map (x: x.name) activeMods);
  mkPkg =
    x:
    pkgs.callPackage ./mod.nix {
      modName = x;
      source = source;
    };
in
map mkPkg modNames
