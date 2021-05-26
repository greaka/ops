{ config, pkgs, ... }:

{
  config = {
    nixpkgs.config.packageOverrides = pkgs: {
      wvwbot = pkgs.callPackage ./package.nix {};
    };
  };
}

