{ buildGoPackage, ... }:
let
  source = builtins.fetchGit {
    url = "git@github.com:greaka/discordwvwbot.git";
    ref = "e20334f398dc55f0eec4254a7a8b7007084d1b3c";
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
