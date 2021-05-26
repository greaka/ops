{ buildGoPackage, ... }:
let
  source = builtins.fetchGit {
    url = "git@github.com:greaka/discordwvwbot.git";
    ref = "master";
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
