{ lib, stdenv, ... }:
with lib; with builtins; let
  source = /home/greaka/.factorio/mods;
  modJson = importJSON /home/greaka/.factorio/mods/mod-list.json;
  activeMods = filter (x: x.enabled) modJson.mods;
  modNames = filter (x: x != "base") (map (x: x.name) activeMods);
  availableFiles = attrNames (readDir source);
  filesOfName = f: filter (x: hasPrefix f x) availableFiles;
  lastVersion = f: last (naturalSort (filesOfName f));
  modFiles = map lastVersion modNames;
in
stdenv.mkDerivation rec {
  pname = "factorio-mods";
  version = "3";
  src = source;
  buildCommand = ''
    mkdir -p $out
    pushd $src
    cp -r ${lib.concatStringsSep " " modFiles} $out
    popd
  '';
  deps = [];
}
