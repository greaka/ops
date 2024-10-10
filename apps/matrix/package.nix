{
  lib,
  pkgs,
  rustPlatform,
  fetchFromGitLab,
  pkg-config,
  rocksdb,
  ...
}:
let
  pname = "matrix-conduit";
  sources = fetchFromGitLab {
    owner = "famedly";
    repo = "conduit";
    rev = "b11855e7a1fc00074a13f9d1b9ab04462931332f";
    sha256 = "sha256-hqjRGQIBmiWpQPhvix8L5rcxeuJ2z0KZS6A6RbmTB/o=";
  };
  crane = import ../../utils/crane { inherit pkgs; };

  sqlFilter = path: _type: null != builtins.match ".*(.sqlx/.*|.sql$)" path;
  sqlOrCargo = path: type: (sqlFilter path type) || (crane.filterCargoSources path type);

  buildFlags = {
    src = lib.cleanSourceWith {
      src = sources;
      filter = sqlOrCargo;
    };
    RUSTFLAGS = [
      "-C"
      "target-cpu=znver2"
    ];
    nativeBuildInputs = [
      rustPlatform.bindgenHook
      pkg-config
    ];

    ROCKSDB_INCLUDE_DIR = "${rocksdb}/include";
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
    doCheck = false;
  };

  cargoArtifacts = crane.buildDepsOnly (buildFlags // { inherit pname; });
in
crane.buildPackage (buildFlags // { inherit pname cargoArtifacts; })
