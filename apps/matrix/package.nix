{ lib, rustPlatform, fetchFromGitLab, pkg-config, sqlite, stdenv, darwin
, nixosTests, rocksdb }:

rustPlatform.buildRustPackage {
  pname = "matrix-conduit";
  version = "0.6.0-next";

  src = fetchFromGitLab {
    owner = "famedly";
    repo = "conduit";
    rev = "e9946f81a09b02b12062e2cb999d6836e467e2d7";
    sha256 = "sha256-C46+7N71/THMkhyfxzHodm1N89w3GDbYat+mn32QjV4=";
  };

  # We have to use importCargoLock here because `cargo vendor` currently doesn't support workspace
  # inheritance within Git dependencies, but importCargoLock does.
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "heed-0.10.6" = "sha256-rm02pJ6wGYN4SsAbp85jBVHDQ5ITjZZd+79EC2ubRsY=";
      "reqwest-0.11.9" = "sha256-wH/q7REnkz30ENBIK5Rlxnc1F6vOyuEANMHFmiVPaGw=";
      "ruma-0.8.2" = "sha256-+CjVDLopvkyunZ7jhkDLgfyGkUpl9069h0xDhmLoijQ=";
    };
  };

  # Conduit enables rusqlite's bundled feature by default, but we'd rather use our copy of SQLite.
  preBuild = ''
    substituteInPlace Cargo.toml --replace "features = [\"bundled\"]" "features = []"
    cargo update --offline -p rusqlite
  '';

  nativeBuildInputs = [ rustPlatform.bindgenHook pkg-config ];

  buildInputs = [ sqlite ]
    ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  ROCKSDB_INCLUDE_DIR = "${rocksdb}/include";
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";

  # tests failed on x86_64-darwin with SIGILL: illegal instruction
  doCheck = !(stdenv.isx86_64 && stdenv.isDarwin);

  passthru.tests = { inherit (nixosTests) matrix-conduit; };

  meta = with lib; {
    description = "A Matrix homeserver written in Rust";
    homepage = "https://conduit.rs/";
    license = licenses.asl20;
    maintainers = with maintainers; [ pstn piegames pimeys ];
    mainProgram = "conduit";
  };
}
