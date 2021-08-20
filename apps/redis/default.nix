{ ... }:
{
  services.redis.enable = true;
  alerts = [ "redis" ];
}
