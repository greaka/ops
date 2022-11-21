{ config, pkgs, ... }:
{
    services.github-runner = {
        enable = true;
        url = "https://github.com/greaka/gw2api";
        replace = true;
        tokenFile = "/run/keys/github-runner";
        package = pkgs.github-runner.override { withNode12 = true; };
        extraPackages = with pkgs; [ cargo rustc gcc binutils-unwrapped ];
    };       

    nixpkgs.config.permittedInsecurePackages = [
        "nodejs-12.22.12"
    ];

    boot.runSize = "16G";

    systemd.services.github-runner.after = [ "github-runner-key.service" ];
    alerts = [ "github-runner" ];
}
