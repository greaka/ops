{ lib, rustPlatform, fetchFromGitLab, pkg-config, sqlite, stdenv, darwin
, nixosTests, rocksdb }:

rustPlatform.buildRustPackage {
  pname = "matrix-conduit";
  version = "next";

  src = fetchFromGitLab {
    owner = "famedly";
    repo = "conduit";
    rev = "3bfdae795d4d9ec9aeaac7465e7535ac88e47756";
    sha256 = "sha256-35SgWnBkWTyyRwVPyUKoShjzXfX0H1+HDdEEjZ/LsXc=";
  };

  # We have to use importCargoLock here because `cargo vendor` currently doesn't support workspace
  # inheritance within Git dependencies, but importCargoLock does.
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "heed-0.10.6" = "sha256-rm02pJ6wGYN4SsAbp85jBVHDQ5ITjZZd+79EC2ubRsY=";
      "reqwest-0.11.9" = "sha256-wH/q7REnkz30ENBIK5Rlxnc1F6vOyuEANMHFmiVPaGw=";
      "ruma-0.8.2" = "sha256-onxniELxrYEfFuobgRgNerzEdHEuT2eZyhydO1fHZm0=";
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
