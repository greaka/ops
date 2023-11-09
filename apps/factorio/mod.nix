{ lib, stdenv, modName, source, ... }:
with lib;
with builtins;
let
  availableFiles = attrNames (readDir source);
  filesOfName = f: filter (x: hasPrefix f x) availableFiles;
  lastVersion = f: last (naturalSort (filesOfName f));
  modVersion = s: elemAt (match ".*_(.*).zip" s) 0;
in stdenv.mkDerivation {
  pname = "factorio-mod-${modName}";
  version = modVersion (lastVersion modName);
  src = source + "/${lastVersion modName}";
  buildCommand = ''
    mkdir -p $out
    cp $src $out/${lastVersion modName}
  '';
  preferLocalBuild = true;
  deps = [ ];
}
