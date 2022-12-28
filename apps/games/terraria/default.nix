{ ... }:

{
  imports = [ ./override.nix ];

  services.terraria = {
    enable = true;
    maxPlayers = 8;
    openFirewall = true;
    #worldPath = "/var/lib/terraria/.local/share/Terraria/Worlds/Ani_+_Belst.wld";
    #worldPath = "/var/lib/terraria/.local/share/Terraria/Worlds/Schmeckers.wld";
    #worldPath = "/var/lib/terraria/.local/share/Terraria/Worlds/Mamey's_Lawn.wld";
    worldPath =
      "/var/lib/terraria/.local/share/Terraria/Worlds/We_are_checking.wld";
  };

  alerts = [ "terraria" ];
  backups = [ "/var/lib/terraria/.local/share/Terraria/Worlds" ];
}
