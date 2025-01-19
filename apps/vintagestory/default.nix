{ pkgs, ... }:
let
  localModPath = /home/greaka/.config/VintagestoryData/Mods;
  stateDirName = "vintagestory";
  datapath = "/var/lib/${stateDirName}";
  user = "vintagestory";
  gendef = pkgs.callPackage ./serverconfig.nix { vintagestory = pkg; };
  defcon = builtins.fromJSON (builtins.readFile "${gendef}/serverconfig.json");
  # https://wiki.vintagestory.at/Server_Config
  config = defcon // {
    StartupCommands = "/op Greaka";
    WorldConfig.WorldType = "wildernesssurvival";
    WorldConfig.SaveFileLocation = "${datapath}/Saves/hindsight.vcdbs";
    AdvertiseServer = false;
    WhitelistMode = "off";
    DieAboveMemoryUsageMb = 6000;
  };
  configFile = builtins.toFile "serverconfig.json" (builtins.toJSON config);
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

          version = "1.20.1";

          src = fetchurl {
            url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${final.version}.tar.gz";
            hash = "sha256-FXguajZ/sKDbUEwkwnjBJcpz5jcM1rrVzqTLXn6TS1M=";
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
        rm -rf ${datapath}/Mods
        ln -fs ${localModPath} ${datapath}/Mods
        ln -fs ${configFile} ${datapath}/serverconfig.json
        ${pkg}/bin/vintagestory-server --dataPath ${datapath}
      ''}/bin/vintagestory.sh";
    };
  };

  networking.firewall.allowedTCPPorts = [ config.Port ];

  alerts = [ "vintagestory" ];
  # It got too big
  # backups = [ "${datapath}/Saves/*" ];
}
