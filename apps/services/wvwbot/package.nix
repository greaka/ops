{ buildGoPackage, ... }:
let
  source = builtins.fetchGit {
    url = "https://github.com/greaka/discordwvwbot.git";
    ref = "9aaf5af332df33c431f381bd7b12b656504590fc";
  };
in
buildGoPackage {
  name = "wvwbot";
  pname = "wvwbot";
  goPackagePath = "github.com/greaka/discordwvwbot";
  src = source;
  goDeps = ./deps.nix;
  postInstall = ''
    cp -r ${source}/templates $out
  '';
}
