{
  config,
  lib,
  pkgs,
  ...
}:
let
  # todo: factorio style mods
  localModPath = /home/greaka/.config/VintagestoryData/Mods;
  stateDirName = "vintagestory";
  dataPath = "/var/lib/${stateDirName}";
  modPath = "${dataPath}/Mods";
  user = "vintagestory";
  gendef = pkgs.callPackage ./serverconfig.nix { vintagestory = pkg; };
  defcon = builtins.fromJSON (builtins.readFile "${gendef}/serverconfig.json");
  # https://wiki.vintagestory.at/Server_Config
  cfg = lib.recursiveUpdate defcon {
    ModPaths = defcon.ModPaths ++ [ modPath ];
    VerifyPlayerAuth = config.hetzner.ipv4 != null;
    StartupCommands = "/op Greaka";
    WorldConfig.WorldType = "wildernesssurvival";
    WorldConfig.SaveFileLocation = "${dataPath}/Saves/hindsight.vcdbs";
    AdvertiseServer = false;
    WhitelistMode = "off";
    DieAboveMemoryUsageMb = 6000;
  };
  configFile = builtins.toFile "serverconfig.json" (builtins.toJSON cfg);
  pkg =
    with pkgs;
    (
      (vintagestory.overrideAttrs (
        final: prev: {
          preFixup = ''
            makeWrapper ${dotnet-runtime_8}/bin/dotnet $out/bin/vintagestory \
            --prefix LD_LIBRARY_PATH : "${prev.runtimeLibs}" \
            --set DOTNET_ROOT ${dotnet-runtime_8}/share/dotnet \
            --set DOTNET_ROLL_FORWARD Major \
            --add-flags $out/share/vintagestory/Vintagestory.dll

            makeWrapper ${dotnet-runtime_8}/bin/dotnet $out/bin/vintagestory-server \
            --prefix LD_LIBRARY_PATH : "${prev.runtimeLibs}" \
            --set DOTNET_ROOT ${dotnet-runtime_8}/share/dotnet \
            --set DOTNET_ROLL_FORWARD Major \
            --add-flags $out/share/vintagestory/VintagestoryServer.dll

            find "$out/share/vintagestory/assets/" -not -path "/fonts/" -regex "./.[A-Z]." | while read -r file; do
            local filename="$(basename -- "$file")"
            ln -sf "$filename" "''${file%/}"/"''${filename,,}"
            done
          '';

          version = "1.20.4";

          src = fetchurl {
            url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${final.version}.tar.gz";
            hash = "sha256-Hgp2u/y2uPnJhAmPpwof76/woFGz4ISUXU+FIRMjMuQ=";
          };
        }
      )).override
      { dotnet-runtime_7 = dotnet-runtime_8; }
    );
in
{
  users.users."${user}" = {
    isSystemUser = true;
    group = "${user}";
  };
  users.groups."${user}" = { };

  systemd.services.vintagestory = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      User = "${user}";
      Restart = "on-failure";
      StateDirectory = stateDirName;
      ExecStart = "${pkgs.writeScriptBin "vintagestory.sh" ''
        #!/bin/sh
        rm -rf ${modPath}
        ln -fs ${localModPath} ${modPath}
        ln -fs ${configFile} ${dataPath}/serverconfig.json
        ${pkg}/bin/vintagestory-server --dataPath ${dataPath}
      ''}/bin/vintagestory.sh";
    };
  };

  networking.firewall.allowedTCPPorts = [ cfg.Port ];
  networking.firewall.allowedUDPPorts = [ cfg.Port ];

  alerts = [ "vintagestory" ];
  # It got too big
  # backups = [ "${dataPath}/Saves/*" ];
}
