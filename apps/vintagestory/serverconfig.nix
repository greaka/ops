{ stdenv, vintagestory, ... }:
let
  pkg = vintagestory;
  tmpDir = "dataPath";
in
stdenv.mkDerivation {
  name = "vintage-story-default-server-config";
  preferLocalBuild = true;
  buildCommand = ''
    mkdir -p "${tmpDir}"
    ${pkg}/bin/vintagestory-server --genconfig --dataPath "${tmpDir}"
    mkdir -p $out
    cp "${tmpDir}/serverconfig.json" $out/serverconfig.json
  '';
}
