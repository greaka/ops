{ config, pkgs, ... }:
let programs = pkgs.callPackage ./package.nix { };
in {
  config = {
    nixpkgs.config.packageOverrides = pkgs: {
      inherit (programs) plik plikd plikd-unwrapped;
    };
  };
}
