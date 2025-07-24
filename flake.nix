{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix = {
      url = "git+https://gerrit.lix.systems/lix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix_2_18.inputs.nixpkgs.follows = "nixpkgs";
      };
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  nixConfig = {
    extra-substituters = [
      "https://cache.lix.systems"
    ];
    extra-trusted-public-keys = [
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
    ];
  };
  outputs =
    {
      nixpkgs,
      colmena,
      lix,
      lix-module,
      ...
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        modules = [ lix-module.nixosModules.default ];
      };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShellNoCC {
        packages = [
          (colmena.packages.x86_64-linux.colmena.override {
            inherit (lix.packages.x86_64-linux) nix-eval-jobs;
          })
          pkgs.nil
          pkgs.helix
        ];
      };

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = pkgs;
        };

        defaults =
          { name, ... }:
          {
            imports = [
              ./common.nix
              ./hetzner
              (./machines + "/${name}")
              ./secrets.nix
              ./apps/alerting
              ./apps/restic
            ];
          };

        kenma =
          { ... }:
          {
            imports = [
              ./apps/atuin
              ./apps/factorio
              ./apps/nginx
              ./apps/ovenmediaengine
              ./apps/plikd
              ./apps/vaultwarden
              ./apps/vintagestory
              ./apps/wireguard
            ];
          };

        # vintage =
        #   { ... }:
        #   {
        #     imports = [ ./apps/vintagestory ];
        #   };
      };
    };
}
