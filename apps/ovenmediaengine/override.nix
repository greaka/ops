{ config, pkgs, ... }:

{
  config = {
    nixpkgs.config.packageOverrides = pkgs: {
      ovenmediaengine = pkgs.callPackage ./package.nix { };
    };
  };
}
