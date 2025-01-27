{ lib, ... }:
with lib;
let
  opt = mkOption {
    type = with types; nullOr str;
    default = null;
  };
in
{
  options.hetzner = {
    ipv4 = opt;
    ipv6 = opt;
    interface = opt;
  };
}
