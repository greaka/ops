{ config, pkgs, ... }:

{
  config = {
    nixpkgs.config.packageOverrides = pkgs: {
      matrix-conduit = pkgs.callPackage ./package.nix { };
    };
  };
}
