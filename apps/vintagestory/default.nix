{ pkgs, ... }:
let
  stateDirName = "vintagestory";
  datapath = "/var/lib/${stateDirName}";
  user = "vintagestory";
  configFile = builtins.toFile "serverconfig.json" (builtins.toJSON config);
  config = (import ./serverconfig.nix) // {
    StartupCommands = "/op Greaka";
    WorldConfig.WorldType = "wildernesssurvival";
    WorldConfig.SaveFileLocation = "${datapath}/Saves/stefan.vcdbs";
    AdvertiseServer = false;
  };
in {
  imports = [ ./override.nix ];

  users.users."${user}" = {
    isSystemUser = true;
    group = "${user}";
  };
  users.groups."${user}" = { };

  systemd.services.vintagestory = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      User = "${user}";
      Restart = "on-failure";
      StateDirectory = stateDirName;
      ExecStart = "${
          pkgs.writeScriptBin "vintagestory.sh" ''
            #!/bin/sh
            ln -fs ${configFile} /var/lib/vintagestory/serverconfig.json
            ${pkgs.vintagestory}/bin/vintagestory-server --dataPath ${datapath}
          ''
        }/bin/vintagestory.sh";
    };
  };

  networking.firewall.allowedTCPPorts = [ config.Port ];

  alerts = [ "vintagestory" ];
  backups = [ "${datapath}/Saves" ];
}
