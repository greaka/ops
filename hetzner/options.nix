{ lib, ... }:
with lib;
let opt = mkOption { type = types.str; };
in {
  options.hetzner = {
    hostName = opt;
    ipv4 = opt;
    ipv6 = opt;
  };
}
