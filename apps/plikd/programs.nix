{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchurl,
  makeWrapper,
  runCommand,
}:

let
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "root-gg";
    repo = "plik";
    rev = "eb5b0276158f7ea9fa289a51c2491e13eaf8559a";
    sha256 = "1hxp14y4kx3rb9hwvrj5f9l04vyi7yv3q6prq0g0nkg7lhf53sqn";
  };

  vendorSha256 = "1j6bjc3x4i6i0hqmqich3i1cfxagx6vmzy00pj4la719xvj3xxkw";

  meta = with lib; {
    homepage = "https://plik.root.gg/";
    description = "Scalable & friendly temporary file upload system";
    maintainers = with maintainers; [ freezeboy ];
    license = licenses.mit;
  };
in
{

  plik = buildGoModule {
    pname = "plik";
    inherit
      version
      meta
      src
      vendorSha256
      ;

    subPackages = [ "client" ];
    postInstall = ''
      mv $out/bin/client $out/bin/plik
    '';
  };

  plikd-unwrapped = buildGoModule {
    pname = "plikd-unwrapped";
    inherit version src vendorSha256;

    subPackages = [ "server" ];
    postFixup = ''
      mv $out/bin/server $out/bin/plikd
    '';
  };
}
