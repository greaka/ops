{ ... }: {
  services.redis.enable = true;
  alerts = [ "redis" ];
  backups = [ "/var/lib/redis/dump.rdb" ];
}
