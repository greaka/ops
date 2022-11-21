{ config, pkgs, ... }:

{
  config = {
    nixpkgs.config.packageOverrides = pkgs: {
      vintagestory = pkgs.callPackage ./package.nix { };
    };
  };
}
