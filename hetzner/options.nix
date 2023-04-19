{ lib, ... }:
with lib;
let opt = mkOption { type = types.str; };
in {
  options.hetzner = {
    ipv4 = opt;
    ipv6 = opt;
  };
}
