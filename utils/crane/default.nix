{ pkgs, ... }:
let
  src = pkgs.fetchFromGitHub {
    owner = "ipetkov";
    repo = "crane";
    rev = "2c94ff9a6fbeb9f3ea0107f28688edbe9c81deaa";
    sha256 = "sha256-jX+B1VGHT0ruHHL5RwS8L21R6miBn4B6s9iVyUJsJJY=";
  };
  local = /git/crane;
in
import local { inherit pkgs; }
