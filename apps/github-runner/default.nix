{ config, ... }:
{
    services.github-runner = {
        enable = true;
        url = "https://github.com/greaka/gw2api";
        replace = true;
        tokenFile = "/run/keys/github-runner";
    };

    alerts = [ "github-runner" ];
}
