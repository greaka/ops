{ pkgs, rustPlatform, lib, ... }:
let
  source = builtins.fetchGit {
    url = "git@github.com:greaka/wvwbot.git";
    rev = "066c654ac9191048115dad0b5dce683ec78330bf";
  };
in rustPlatform.buildRustPackage {
  name = "wvwbot";
  pname = "wvwbot";
  src = source;
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "loki-api-0.1.0" = "1i9rwgx174zs10r2s9fzz7nn4bl9mb24mx7h2hgbaxnrwgzx7k70";
      "twilight-cache-inmemory-0.15.1" =
        "1h6936i41936qck1vb8gkjbppg17llflq3s5p4i5xc20xqn56f2n";
      "twilight-http-ratelimiting-0.15.1" =
        "0h6igjhrq5wfk54qra92jy07q5c12viqzkavd2lm3mbq8bd930qx";
    };
  };
  cargoHash = lib.fakeHash;
  nativeBuildInputs = with pkgs; [ cmake cacert ];
  RUSTFLAGS = [ "-C" "target-cpu=znver2" ];
  doCheck = false;
}
