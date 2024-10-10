{
  hosts,
  logDir,
  pkgs,
  stdenv,
  ...
}:
let
  server = pkgs.callPackage ./server.nix { inherit hosts; };
  logger = pkgs.callPackage ./logger.nix { inherit hosts logDir; };
in
stdenv.mkDerivation {
  name = "ovenmediaengine-config";

  buildCommand = ''
    mkdir -p $out
    ln -s ${server} $out/Server.xml
    ln -s ${logger} $out/Logger.xml
  '';
}
