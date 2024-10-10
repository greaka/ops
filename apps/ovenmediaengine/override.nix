{ config, pkgs, ... }:

{
  config = {
    nixpkgs.config.packageOverrides = pkgs: { oven-media-engine = pkgs.callPackage ./package.nix { }; };
  };
}
