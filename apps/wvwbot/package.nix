{ lib, pkgs, ... }:
let
  pname = "wvwbot";
  sources = /git/wvwbot;
  crane = import ../../utils/crane { inherit pkgs; };

  sqlFilter = path: _type: null != builtins.match ".*(.sqlx/.*|.sql$)" path;
  sqlOrCargo = path: type:
    (sqlFilter path type) || (crane.filterCargoSources path type);

  buildFlags = {
    src = lib.cleanSourceWith {
      src = sources;
      filter = sqlOrCargo;
    };
    RUSTFLAGS = [ "-C" "target-cpu=znver2" ];
    nativeBuildInputs = with pkgs; [ cmake ];
    doCheck = false;
  };

  cargoArtifacts = crane.buildDepsOnly (buildFlags // { inherit pname; });
in crane.buildPackage (buildFlags // { inherit pname cargoArtifacts; })
