{
  lib,
  stdenv,
  pkgs,
  api,
  username,
  token,
  factorioVersion,
  ...
}:
with lib;
with builtins;
let
  baseUrl = "https://mods.factorio.com";
  releases = filter (x: x.info_json.factorio_version == factorioVersion) api.releases;
  releasesSorted = naturalSort (map (x: x.version) releases);
  lastRelease = last releasesSorted;
  release = head (filter (x: x.version == lastRelease) releases);
  asset = last (splitString "/" release.download_url);
in
stdenv.mkDerivation {
  pname = "factorio-mod-${api.name}";
  version = release.version;
  src = pkgs.fetchurl {
    name = "factorio-modraw-${api.name}-${asset}";
    url = "${baseUrl}${release.download_url}?username=${username}&token=${token}";
    sha1 = release.sha1;
  };
  buildCommand = ''
    mkdir -p $out
    ln -s $src $out/${release.file_name}
  '';
  deps = [ ];
}
