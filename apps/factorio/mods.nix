{ config, lib, pkgs, ... }:
with lib;
with builtins;
let
  srcUser = "greaka";
  userFolder = /home + "/${srcUser}" + /.factorio;
  modsBaseUrl = "https://mods.factorio.com/api/mods";
  playerData = importJSON "${userFolder}/player-data.json";
  factorioVersion = config.services.factorio.package.version;
  factorioMajorMinor = match "^([^.]+\.[^.]+)\..*" factorioVersion;
  versionStr = head factorioMajorMinor;
  modJson = importJSON "${userFolder}/mods/mod-list.json";
  activeMods = map (x: x.name) (filter (x: x.enabled) modJson.mods);
  commaMods = replaceStrings [" "] [","] (toString activeMods);
  modsRes = fetchurl {
    url = "${modsBaseUrl}?page_size=max&version=${versionStr}&namelist=${commaMods}";
    name = "factorio-mods-api-response";
  };
  modsApi = importJSON modsRes;
  mods = if modsApi.pagination == null then modsApi.results else throw "too many factorio mods, fix the pagination of the script";
  mkPkg =
    x:
    pkgs.callPackage ./mod.nix {
      api = x;
      username = playerData."service-username";
      token = playerData."service-token";
      factorioVersion = versionStr;
    };
in
map mkPkg mods
